# frozen_string_literal: true

class AuthenticationController < ApplicationController
  include Concerns::AccessToken

  before_action :load_credential, only: [:retrieve_access_token]

  def login
    credential = platform.credentials.last
    @client_id = credential.oauth_client_id
    @redirect_uri = redirect_uri
    @authorization_redirect = authorization_redirect
    @state, @nonce = create_and_cache_state
  end

  def retrieve_access_token
    fetch_access_token
  end

  def view_token
    render(json: { message: "must set scopes" }, status: :bad_request) and return if scopes.blank?
    credential
    retrieve_and_set_token
    render json: {
      message: "Current access token for: #{platform.platform_iss}##{credential.id}.",
      redis_message: AccessTokenStorageService.get_access_token(access_token_key)
    }
  end

  def clear_token
    credential
    render json: {
      message: "Cleared tokens for iss and credential: #{platform.platform_iss}##{credential.id}.",
      redis_message: AccessTokenStorageService.clear_token(access_token_key)
    }
  end

  private

  def authorization_redirect
    credential.authentication_redirect_override || platform.authentication_redirect_endpoint
  end

  def create_and_cache_state
    state = SecureRandom.uuid
    nonce = SecureRandom.uuid
    StateStoreService.set_state(nonce, state)
    [state, nonce]
  end

  def redirect_uri
    redirect_params = {
      placement: params[:placement]
    }.merge(Rack::Utils.parse_nested_query(target_link_uri.query))
    launch_url(params: redirect_params)
  end

  def scopes
    Token::ScopesCreator.parse_scopes(params[:scopes] || @credential.requested_scopes)
  end

  def target_link_uri
    URI.parse(params[:target_link_uri])
  end
end
