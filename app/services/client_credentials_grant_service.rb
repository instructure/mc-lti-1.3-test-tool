# frozen_string_literal: true

class ClientCredentialsGrantService
  CLIENT_ASSERTION_TYPE = 'urn:ietf:params:oauth:client-assertion-type:jwt-bearer'
  GRANT_TYPE = 'client_credentials'

  attr_reader :request

  def initialize(grant_url, credential, scopes = [:ags_all])
    @grant_url = grant_url
    @credential = credential
    @scopes = Token::ScopesCreator.new(scopes).create_scope_string
  end

  def make_request
    Rails.logger.info("AccessToken requested with: #{prepare_request}")
    @request = HTTParty.post(@grant_url, prepare_request)
  end

  def valid?
    @request.success?
  end

  def request_token
    make_request if @request.nil?
    valid? ? JSON.parse(@request.body) : { error_code: @request.code, error_body: @request.body }
  end

  def prepare_request
    @prepare_request ||= {
      body: request_body.to_json,
      headers: { 'Content-Type' => 'application/json' }
    }
  end

  private

  def jws
    JSON::JWT.new(
      iss: 'ltitesttool.docker',
      sub: @credential.oauth_client_id,
      aud: aud,
      iat: Time.zone.now,
      exp: 10.minutes.from_now,
      jti: SecureRandom.uuid
    ).sign(JSON::JWK.new(@credential.private_key), :RS256).to_s
  end

  def aud
    u = URI(@grant_url)
    "#{u.scheme}://#{u.host}#{u.path}"
  end

  def request_body
    {
      grant_type: 'client_credentials',
      client_assertion_type: 'urn:ietf:params:oauth:client-assertion-type:jwt-bearer',
      client_assertion: jws,
      scope: @scopes
    }
  end
end
