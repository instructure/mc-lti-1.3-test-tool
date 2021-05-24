# frozen_string_literal: true

require 'spec_helper'

describe LaunchController do
  let(:jws) do
    Token::JwtCreator.create_jws_from_platform
  end
  let(:state) { SecureRandom.uuid }
  let(:redis_double) { double(set: true, get: state) }

  before { allow(Redis).to receive(:current).and_return(redis_double) }

  shared_examples_for 'launch' do
    context 'with successful launch' do
      before do
        post :launch, params: { id_token: jws, state: state }
      end

      subject { response }

      it { is_expected.to have_http_status(:ok) }
    end

    context 'with invalid state launch' do
      before do
        post :launch, params: { id_token: jws, state: 'invalid_state' }
      end

      subject { response }

      it { is_expected.to have_http_status(:unauthorized) }

      it 'includes an error message' do
        errors = JSON.parse(response.body)['error']
        expect(errors.first['errors']).to match_array ['State is invalid.']
      end
    end

    context 'with invalid audience launch' do
      let(:invalid_aud_jws) do
        decoded_jws = JSON::JWT.decode(Token::JwtCreator.create_jws_from_platform, :skip_verification)
        decoded_jws['aud'] = aud
        decoded_jws['azp'] = azp
        jwt = JSON::JWT.new(decoded_jws)
        jwt.sign(JSON::JWK.new(Token::JWKS.values.sample(1).first), :RS256).to_s
      end

      context 'when azp is not in the aud' do
        let(:aud) { ['aud'] }
        let(:azp) { 'azp' }
        before do
          post :launch, params: { id_token: invalid_aud_jws, state: state }
        end
        subject { response }
        it { is_expected.to have_http_status(:unauthorized) }
      end

      context 'when public key do not match one of the client_ids' do
        let(:aud) { ['aud'] }
        let(:azp) { 'aud' }
        before do
          post :launch, params: { id_token: invalid_aud_jws, state: state }
        end
        subject { response }
        it { is_expected.to have_http_status(:unauthorized) }
      end

      context 'when aud does not exist in credentials' do
        let(:aud) { ['invalid'] }
        let(:azp) { 'invalid' }
        before do
          post :launch, params: { id_token: invalid_aud_jws, state: state }
        end
        subject { response }
        it { is_expected.to have_http_status(:unauthorized) }
      end
    end
  end

  describe '#launch' do
    context 'using local jwks' do
      around do |example|
        ClimateControl.modify use_local_jwks: 'true' do
          example.run
        end
      end

      it_behaves_like 'launch'
    end

    context 'using public jwks' do
      before do
        jws
        platform = Platform.first
        jwk_json = Token::JWKS.values.to_json
        expect(HTTParty).to(
          receive(:get).with(platform.public_key_endpoint).and_return(OpenStruct.new(body: jwk_json))
        )
      end

      around do |example|
        ClimateControl.modify use_local_jwks: 'false' do
          example.run
        end
      end

      it_behaves_like 'launch'
    end
  end
end
