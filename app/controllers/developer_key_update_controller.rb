# frozen_string_literal: true

class DeveloperKeyUpdateController < ApplicationController
  include Concerns::AdvantageConcerns

  before_action :load_credential

  def update_jwk
    private_key = OpenSSL::PKey::RSA.new(2048)
    pub_key = private_key.public_key.to_jwk(alg: :RS256, use: 'sig').to_h
    service_render service.put(pub_key)
    return unless service.success?
    @credential.update!(
      private_key: private_key.to_jwk(alg: :RS256, use: 'sig').to_h,
      public_key: pub_key
    )
  end

  def external_access_for_jwk
    pub_key = @credential.public_key
    render json: { keys: [pub_key] }
  end

  private

  def service
    @service ||= DeveloperKeyUpdateService.new(platform.update_jwk_endpoint, fetch_access_token)
  end
end
