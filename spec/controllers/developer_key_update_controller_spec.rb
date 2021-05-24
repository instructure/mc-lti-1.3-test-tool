# frozen_string_literal: true

require 'spec_helper'

describe DeveloperKeyUpdateController do
  subject { get :update_jwk, params: { credential_id: credential_id } }

  let(:iss) { "https://canvas.instructure.com" }
  let!(:platform) do
    Factories::PlatformFactory.new(platform_iss: iss).create_new_platform
  end
  let(:credential) { platform.credentials.first }
  let(:credential_id) { credential.id }
  let(:response_body) { { public_jwk: "hello" }.with_indifferent_access }
  let(:service) { double(success?: true, put: response_body.to_json) }
  let(:scopes) { [:all] }
  let(:old_pkey) { credential.private_key }
  let(:old_pubkey) { credential.public_key }
  let(:private_key) { OpenSSL::PKey::RSA.new(2048) }
  let(:public_key) do
    key_hash = private_key.public_key.to_jwk(alg: 'RS256', use: 'sig').to_h
    key_hash['kty'] = key_hash['kty'].to_s
    key_hash
  end
  let(:private_jwk) do
    pkey_hash = private_key.to_jwk(alg: 'RS256', use: 'sig').to_h
    pkey_hash['kty'] = pkey_hash['kty'].to_s
    pkey_hash
  end

  before do
    credential
    old_pkey
    old_pubkey
    allow(controller).to receive(:service).and_return(service)
    allow(OpenSSL::PKey::RSA).to receive(:new).and_return(private_key)
    subject
  end

  context 'when save is successful' do
    it { is_expected.to be_successful }

    it 'updates the public key' do
      expect(credential.reload.public_key).to eq public_key
    end

    it 'updates the private key' do
      expect(credential.reload.private_key).to eq private_jwk
    end

    it 'forwards the response from the platform' do
      expect(JSON.parse(response.body)).to eq response_body
    end
  end

  context 'when save is not successful' do
    let(:service) { double(success?: false, put: response_body.to_json) }
    let(:response_body) { { error: 'there was an error' }.with_indifferent_access }

    it { is_expected.to be_successful }

    it 'does not update the public key' do
      expect(credential.reload.public_key).to eq old_pubkey
    end

    it 'does not update the private key' do
      expect(credential.reload.private_key).to eq old_pkey
    end

    it 'forwards the error response from the platform' do
      expect(JSON.parse(response.body)).to eq response_body
    end
  end
end
