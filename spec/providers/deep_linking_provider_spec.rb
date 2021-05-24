# frozen_string_literal: true

require 'spec_helper'
require 'timecop'

describe DeepLinkingProvider do

  let(:deployment_id) { SecureRandom.uuid }
  let(:content_items) { ['Content Item'] }
  let(:message) { 'A message' }
  let(:error_message) { 'error message' }
  let(:iss) { '1000000000006' }
  let(:aud) { 'canvas' }
  let_once(:platform) { Factories::PlatformFactory.new(no_populate: true).create_new_platform }

  before do
    pkey = OpenSSL::PKey::RSA.new(2048)
    Credential.create!(
      platform: platform,
      oauth_client_id: iss,
      private_key: pkey.to_jwk(alg: :RS256, use: 'sig').to_h,
      public_key: pkey.public_key.to_jwk(alg: :RS256, use: 'sig').to_h
    )
  end

  describe '#create_jws' do
    subject do
      jws = DeepLinkingProvider.create_jws(
        iss: iss,
        aud: aud,
        deployment_id: deployment_id,
        content_items: content_items,
        message: message,
        error_message: error_message
      )
      JSON::JWT.decode(jws, JSON::JWK.new(Credential.find_by!(oauth_client_id: iss).public_key))
    end

    it 'uses the correct message type' do
      expect(subject['https://purl.imsglobal.org/spec/lti/claim/message_type']).to eq 'LtiDeepLinkingResponse'
    end

    it 'uses the correct lti version' do
      expect(subject['https://purl.imsglobal.org/spec/lti/claim/version']).to eq '1.3.0'
    end

    it 'uses the specified deployment id' do
      expect(subject['https://purl.imsglobal.org/spec/lti/claim/deployment_id']).to eq deployment_id
    end

    it 'uses the specified content items' do
      expect(subject['https://purl.imsglobal.org/spec/lti-dl/claim/content_items']).to match_array content_items
    end

    it 'uses the specified message' do
      expect(subject['https://purl.imsglobal.org/spec/lti-dl/claim/msg']).to eq message
    end

    it 'uses the specified error message' do
      expect(subject['https://purl.imsglobal.org/spec/lti-dl/claim/errormsg']).to eq error_message
    end

    it 'uses the specified iss' do
      expect(subject['iss']).to eq iss
    end

    it 'uses the specified aud' do
      expect(subject['aud']).to eq aud
    end

    it 'sets the "iat" to the current time' do
      Timecop.freeze(Time.zone.now) do
        expect(subject['iat']).to eq Time.zone.now.to_i
      end
    end

    it 'sets the "exp" to five minutes from now' do
      Timecop.freeze(Time.zone.now) do
        expect(subject['exp']).to eq 5.minutes.from_now.to_i
      end
    end
  end
end
