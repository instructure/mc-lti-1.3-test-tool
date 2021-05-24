# frozen_string_literal: true

class PublicJwkService
  def initialize(public_jwk_url)
    @public_jwk_url = public_jwk_url
  end

  def public_jwk_set
    response = if ENV['use_local_jwks'] == 'true'
                 Token::JwtCreator.public_keyset
               else
                 JSON.parse(HTTParty.get(@public_jwk_url).body)
               end
    JSON::JWK::Set.new(response)
  end
end
