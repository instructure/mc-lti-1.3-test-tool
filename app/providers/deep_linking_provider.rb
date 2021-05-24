# frozen_string_literal: true

class DeepLinkingProvider
  RESPONSE_MESSAGE_TYPE = 'LtiDeepLinkingResponse'
  LTI_VERSION = '1.3.0'

  class << self
    # TODO: Refactor into a model like lib/models/content_item.rb
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/ParameterLists
    # rubocop:disable Layout/LineLength
    def create_jws(iss:, aud:, deployment_id:, log: nil, error_log: nil, content_items: [], message: nil, error_message: nil, alg: :RS256)
      body = {
        "iss" => iss,
        "aud" => aud,
        "iat" => Time.zone.now.to_i,
        "exp" => 5.minutes.from_now.to_i,
        "nonce" => SecureRandom.uuid,
        "https://purl.imsglobal.org/spec/lti/claim/message_type" => RESPONSE_MESSAGE_TYPE,
        "https://purl.imsglobal.org/spec/lti/claim/version" => LTI_VERSION,
        "https://purl.imsglobal.org/spec/lti/claim/deployment_id" => deployment_id,
        "https://purl.imsglobal.org/spec/lti-dl/claim/content_items" => content_items,
        "https://purl.imsglobal.org/spec/lti-dl/claim/msg" => message,
        "https://purl.imsglobal.org/spec/lti-dl/claim/errormsg" => error_message,
        "https://purl.imsglobal.org/spec/lti-dl/claim/log" => log,
        "https://purl.imsglobal.org/spec/lti-dl/claim/errorlog" => error_log
      }
      JSON::JWT.new(body).sign(jwk(iss), alg).to_s
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/ParameterLists
    # rubocop:enable Layout/LineLength

    def jwk(iss)
      JSON::JWK.new(Credential.find_by!(oauth_client_id: iss).private_key)
    end
  end
end
