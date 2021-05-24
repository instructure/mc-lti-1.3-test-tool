# frozen_string_literal: true

require 'spec_helper'

describe ClientCredentialsGrantService do
  let(:service) { described_class.new(platform.grant_url, credential, scopes) }
  let(:platform) { Factories::PlatformFactory.new(save_public_key: true).create_new_platform }
  let(:credential) { platform.credentials.first }
  let(:body) do
    {
      grant_type: 'client_credentials',
      client_assertion_type: 'urn:ietf:params:oauth:client-assertion-type:jwt-bearer',
      client_assertion: jws,
      scope: 'https://purl.imsglobal.org/spec/lti-nrps/scope/contextmembership.readonly'
    }
  end
  let(:scopes) { [:nrps_all] }
  let(:headers) { { 'Content-Type' => 'application/json' } }
  let(:parsed_body) { JSON.parse(subject[:body]).with_indifferent_access }
  let(:jws) { parsed_body[:client_assertion] }
  let(:decoded_jwt) { JSON::JWT.decode(jws, JSON::JWK.new(credential.public_key), :RS256) }

  describe '#prepare_request' do
    subject { service.prepare_request }

    it 'puts out the proper request params' do
      expect(subject.keys).to eq %i[body headers]
    end

    it 'creates a jws with the correct signing key' do
      expect { decoded_jwt }.to_not raise_error
    end

    it 'creates a request with the expected fields' do
      expect(parsed_body.keys).to eq %w[grant_type client_assertion_type client_assertion scope]
    end

    it 'creates a jws with the expected fields' do
      expect(decoded_jwt.keys).to eq %w[iss sub aud iat exp jti]
    end

    it 'creates the expected scopes' do
      expect(parsed_body[:scope]).to eq 'https://purl.imsglobal.org/spec/lti-nrps/scope/contextmembership.readonly'
    end
  end

  describe '#request_token' do
    subject { service.request_token }

    before do
      expect(HTTParty).to(
        receive(:post)
        .with(platform.grant_url, service.prepare_request)
        .and_return(OpenStruct.new(body: { body: { test: 'hi' } }.to_json))
      )
      expect(service).to receive(:valid?).and_return(true)
    end

    it 'calls the correct url' do
      expect(subject['body']['test']).to eq 'hi'
    end
  end
end
