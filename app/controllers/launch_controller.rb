# frozen_string_literal: true

class LaunchController < ApplicationController
  COOKIE_NAME = "my_secret_session"
  include CanvasLtiThirdPartyCookies::SafariLaunch

  before_action lambda {
    handle_safari_launch(placement: decoded_jwt["https://www.instructure.com/placement"], window_type: :new_window)
  }

  def launch
    if jwt_verifier.verify_jwt && state_verifier.valid?
      set_instance_data!
    else
      error_render(
        OpenStruct.new(
          message: [{ errors: [*jwt_verifier.errors, *state_verifier.errors] }, { id_token: id_token }]
        ),
        :unauthorized
      )
    end
  end

  private

  # rubocop:disable Metrics/AbcSize
  def set_instance_data!
    @id_token = decoded_jwt
    @public_endpoint = platform.public_key_endpoint
    @deployment_id = deployment_id
    @iss = platform.credentials.take.oauth_client_id
    @aud = decoded_jwt['iss']
    @deep_link_return_url = deep_linking_settings&.dig('deep_link_return_url')
    @deep_link_accept_multiple = deep_linking_settings&.dig('accept_multiple').present?
    @success_return_url = launch_presentation&.dig('return_url')
    process_launch
  end
  # rubocop:enable Metrics/AbcSize

  def process_launch
    # NOTE: that setting cookies at all in local development doesn't work
    # unless the tool is using https, since same_site: none requires secure
    response.set_cookie(COOKIE_NAME,
                        value: SecureRandom.uuid,
                        httponly: true,
                        secure: request.ssl?,
                        same_site: :none)
  end

  def jwt_verifier
    @jwt_verifier ||= JwtVerifier.new(decoded_jwt, platform.credentials)
  end

  def state_verifier
    @state_verifier ||= StateVerifier.new(decoded_jwt['nonce'], state)
  end

  def state
    params.require(:state)
  end

  def id_token
    params.require(:id_token)
  end

  def deployment_id
    decoded_jwt["https://purl.imsglobal.org/spec/lti/claim/deployment_id"]
  end

  def decoded_jwt
    @decoded_jwt ||= begin
      jwk_set = PublicJwkService.new(public_key_endpoint).public_jwk_set
      JSON::JWT.decode id_token, jwk_set
    end
  end

  def public_key_endpoint
    credential&.public_jwk_endpoint_override || platform.public_key_endpoint
  end

  def deep_linking_settings
    decoded_jwt['https://purl.imsglobal.org/spec/lti-dl/claim/deep_linking_settings']
  end

  def launch_presentation
    decoded_jwt['https://purl.imsglobal.org/spec/lti/claim/launch_presentation']
  end

  def platform
    @platform ||= begin
      extracted_issuer_id = JSON::JWT.decode(id_token, :skip_verification)[:iss]
      Platform.find_by!(platform_iss: extracted_issuer_id)
    end
  end

  def credential
    @credential ||= begin
      extracted_aud = JSON::JWT.decode(id_token, :skip_verification)[:aud]
      Credential.find_by(oauth_client_id: extracted_aud)
    end
  end
end
