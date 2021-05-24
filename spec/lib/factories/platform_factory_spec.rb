# frozen_string_literal: true

require 'spec_helper'
require 'openssl'
### Shared Examples

shared_examples_for 'creates new credentials' do
  let(:created_credential) do
    subject.is_a?(Credential) ? subject : subject.credentials.first
  end
  it 'creates a new credentials' do
    expect { subject }.to change { Credential.count }.by 1
  end

  context 'with specified oauth_client_id' do
    let(:oauth_client_id) { 'myclientid' }
    let(:private_key) { OpenSSL::PKey::RSA.new(2048) }

    it 'uses the specified id' do
      expect(created_credential.oauth_client_id).to eq oauth_client_id
    end

    context 'with empty private_key' do
      let(:private_key) { nil }
      let(:jwk) do
        {
          "kty" => "EC",
          "crv" => "P-256",
          "x" => "f83OJ3D2xF1Bg8vub9tLe1gHMzV76e8Tus9uPHvRVEU",
          "y" => "x_FEzRu9m36HLN_tue659LNpXW6pCyStikYjKIWI5a0",
          "kid" => "10000000003"
        }
      end
      let(:created_private_key) do
        model = subject.respond_to?(:private_key) ? subject : subject.credentials.first
        model.private_key
      end

      before do
        allow_any_instance_of(OpenSSL::PKey::RSA).to(
          receive(:to_jwk).and_return(jwk)
        )
      end

      it 'sets a random private_key' do
        expect(created_private_key).to eq jwk
      end
    end
  end

  context 'with save_public_key' do
    let(:save_public_key) { true }

    it 'saves the public_key' do
      expect(created_credential.public_key).to_not be_blank
    end
  end

  context 'with specified private_key' do
    let(:oauth_client_id) { 'myclientkey' }
    let(:private_key) { OpenSSL::PKey::RSA.new(2048) }

    it 'uses the specified key' do
      expect(JSON::JWK.new(created_credential.private_key)).to(
        eq private_key.to_jwk(alg: :RS256, use: 'sig').as_json
      )
    end

    context 'with save_public_key' do
      let(:save_public_key) { true }

      it 'does not save the public_key' do
        expect(created_credential.public_key).to be_blank
      end
    end

    context 'with missing oauth_client_id' do
      let(:oauth_client_id) { nil }
      let(:uuid) { '2581d647-23bb-47fb-a8ff-5afd20c8aed7' }
      let(:created_oauth_client_id) do
        model = subject.respond_to?(:credentials) ? subject.credentials.first : subject
        model.oauth_client_id
      end

      before { allow(SecureRandom).to(receive(:uuid).and_return(uuid)) }

      it 'sets to a random uuid' do
        expect(created_oauth_client_id).to eq uuid
      end
    end
  end
end

shared_examples_for 'returns a platform' do
  it 'returns a platform' do
    expect(subject).to be_a Platform
  end
end

shared_examples_for 'no new deployments/contexts/resources' do
  it 'does not create new deployments' do
    expect { subject }.to change { Deployment.count }.by 0
  end

  it 'does not create new contexts' do
    expect { subject }.to change { Context.count }.by 0
  end

  it 'does not create new resources' do
    expect { subject }.to change { Resource.count }.by 0
  end
end

shared_examples_for 'creates new deployments/contexts/resources' do
  it 'creates new deployments' do
    expect { subject }.to change { Deployment.count }.by 1
  end

  it 'creates new contexts' do
    expect { subject }.to change { Context.count }.by 1
  end

  it 'creates new resources' do
    expect { subject }.to change { Resource.count }.by 1
  end
end

shared_examples_for 'new platform model only' do
  it_behaves_like 'returns a platform'

  it 'does not create new credentials' do
    expect { subject }.to change { Credential.count }.by 0
  end

  it_behaves_like 'no new deployments/contexts/resources'

  context 'with defined platform_guid' do
    let(:platform_guid) { 'madeupguid' }

    it 'saves the platform_guid' do
      expect(subject.platform_guid).to eq(platform_guid)
    end
  end

  context 'with defined platform_url' do
    let(:platform_url) { 'https://testplatform.example.com' }

    it 'saves the platform_iss' do
      expect(subject.platform_iss).to eq(platform_url)
    end

    it 'is used in the public_key_endpoint' do
      expect(subject.public_key_endpoint).to include(platform_url)
    end

    context 'with invalid scheme' do
      let(:platform_url) { 'htp://testplatform.example.com' }

      it 'modifies the platform_iss' do
        expect(subject.platform_iss).to eq('https://testplatform.example.com')
      end

      context 'with nil scheme' do
        let(:platform_url) { 'testplatform.example.com' }

        it 'modifies the platform_iss' do
          expect(subject.platform_iss).to eq('https://testplatform.example.com')
        end
      end
    end

    context 'with platform_iss' do
      let(:platform_iss) { 'https://testplatformiss.example.com' }
      let(:platform_url) { 'https://testplatform.example.com' }

      it 'ignores the platform_url for platform_iss' do
        expect(subject.platform_iss).to_not eq('https://testplatform.example.com')
        expect(subject.platform_iss).to eq(platform_iss)
      end
    end

    context 'with public_key_endpoint' do
      let(:public_key_endpoint) { 'https://testplatformiss.example.com/lti/jwks/custom' }
      let(:platform_url) { 'https://testplatform.example.com' }

      it 'is not used in the public_key_endpoint' do
        expect(subject.public_key_endpoint).to_not include(platform_url)
        expect(subject.public_key_endpoint).to eq public_key_endpoint
      end
    end

    context 'sets the authentication_redirect_endpoint' do
      let(:authentication_redirect_endpoint) { 'https://testplatformiss.example.com/redirect' }
      let(:platform_url) { 'https://testplatform.example.com' }

      it 'is not used in the public_key_endpoint' do
        expect(subject.authentication_redirect_endpoint).to eq authentication_redirect_endpoint
      end
    end
  end
end

describe Factories::PlatformFactory do
  let(:opts) do
    {
      platform_iss: platform_iss,
      platform_url: platform_url,
      platform_guid: platform_guid,
      public_key_endpoint: public_key_endpoint,
      no_populate: no_populate,
      private_key: private_key,
      oauth_client_id: oauth_client_id,
      save_public_key: save_public_key,
      authentication_redirect_endpoint: authentication_redirect_endpoint
    }
  end
  let(:platform_iss) { nil }
  let(:platform_url) { nil }
  let(:platform_guid) { nil }
  let(:public_key_endpoint) { nil }
  let(:no_populate) { false }
  let(:private_key) { nil }
  let(:oauth_client_id) { nil }
  let(:save_public_key) { false }
  let(:authentication_redirect_endpoint) { nil }

  describe '.create_new_platform' do
    subject { described_class.new(opts).create_new_platform }

    context 'with existing platform' do
      let!(:exisiting_platform) { described_class.new(opts).create_new_platform }

      before do
        opts.merge! platform_iss: exisiting_platform.platform_iss
      end

      it 'does not create a new platform' do
        expect { subject }.to change { Platform.count }.by 0
      end

      it_behaves_like 'new platform model only'
    end

    context 'with new platform' do
      it 'creates a new platform' do
        expect { subject }.to change { Platform.count }.by 1
      end

      it_behaves_like 'returns a platform'
      it_behaves_like 'creates new credentials'
      it_behaves_like 'creates new deployments/contexts/resources'

      context 'with no_populate set to true in opts' do
        let(:no_populate) { true }

        it_behaves_like 'new platform model only'
      end
    end
  end

  describe '.create_new_credentials' do
    subject { described_class.new(opts).create_new_credentials }

    let(:platform_iss) { described_class.new(no_populate: true).create_new_platform[:platform_iss] }

    it 'returns a Credential' do
      expect(subject).to be_a Credential
    end
    it_behaves_like 'creates new credentials'
    it_behaves_like 'creates new deployments/contexts/resources'

    context 'with non-existing platform' do
      let(:platform_iss) { 'notexistent' }

      shared_examples_for 'raises RecordNotFound Error' do
        it 'raises a RecordNotFound Error' do
          expect { subject }.to raise_error ActiveRecord::RecordNotFound
        end
      end

      context 'by platform_iss' do
        it_behaves_like 'raises RecordNotFound Error'
      end

      context 'by platform_id' do
        it_behaves_like 'raises RecordNotFound Error'
      end
    end

    context 'with no_populate set to true in opts' do
      let(:no_populate) { true }

      it_behaves_like 'creates new credentials'
      it_behaves_like 'no new deployments/contexts/resources'
    end
  end
end
