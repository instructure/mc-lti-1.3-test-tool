# frozen_string_literal: true

module ControllerMacros
  extend ActiveSupport::Concern

  included do
    let(:key_file) do
      {
        'private_jwk' => private_jwk,
        'public_jwk' => public_jwk
      }
    end
    let(:private_jwk) { { 'kty' => 'RSA', kid: 'private' } }
    let(:public_jwk) { { 'kty' => 'RSA', kid: 'public' } }
  end
end
