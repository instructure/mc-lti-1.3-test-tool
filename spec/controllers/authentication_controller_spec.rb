# frozen_string_literal: true

require 'spec_helper'

describe AuthenticationController do
  let(:iss) { "https://canvas.instructure.com" }
  let(:target_link_uri) { "http://canvas.instructure.com/lti_redirect" }
  let(:valid_params) do
    {
      iss: iss,
      login_hint: "82fe508b8776d939f06c5dda055011d1",
      target_link_uri: target_link_uri,
      lti_message_hint: "6bebb20de28ad4314b5f9b04bed891a1adff7c4",
      placement: "course_navigation"
    }
  end
  let(:state) { SecureRandom.uuid }
  let(:redis_double) { double(set: true, get: state) }
  let!(:platform) do
    Factories::PlatformFactory.new(platform_iss: iss).create_new_platform
  end
  let(:credential) { platform.credentials.first }

  before do
    allow(Redis).to receive(:current).and_return(redis_double)
    allow(SecureRandom).to receive(:uuid).and_return(state)
  end

  describe '#login' do
    subject do
      post :login, params: valid_params
      assigns
    end

    it 'correctly sets the client_id' do
      expect(subject[:client_id]).to eq platform.credentials.first.oauth_client_id
    end

    it 'correctly sets the redirect_uri' do
      expect(subject[:redirect_uri]).to eq 'http://test.host/launch?placement=course_navigation'
    end

    it 'correctly sets the authorization_redirect' do
      expect(subject[:authorization_redirect]).to eq platform.authentication_redirect_endpoint
    end

    it 'caches the state' do
      expect(redis_double).to receive(:set).with(kind_of(String), state, ex: 5.minutes)
      subject
    end

    context 'when the target_link_uri contains query parameters' do
      let(:target_link_uri) { "http://canvas.instructure.com/lti_redirect?some_var=foo" }

      it 'merges the target_link_uri params into the redirect_uri params' do
        expect(subject[:redirect_uri]).to eq 'http://test.host/launch?placement=course_navigation&some_var=foo'
      end
    end
  end

  describe '#retrieve_access_token' do
    subject { assigns(:token).to_json }

    let(:grant_service) { double(request_token: token.merge(access_token: 'othertoken')) }
    let(:redis_double) { double(set: true, get: token.to_json, del: true) }
    let(:scopes) { [:ags_all] }
    let(:token) do
      {
        access_token: 'atoken',
        token_type: 'Bearer',
        expires_in: 3600,
        scope: Token::ScopesCreator.new(scopes).create_scope_string
      }.with_indifferent_access
    end
    let(:valid_params) { { iss: iss, credential_id: credential.id } }

    before do
      allow(controller).to receive(:grant_service).and_return(grant_service)
      get :retrieve_access_token, params: valid_params
    end

    it { is_expected.to eq token.to_json }

    context 'with no cached token' do
      let(:redis_double) { double(set: true, get: nil) }

      it { is_expected.to_not eq token.to_json }
      it { is_expected.to eq token.merge(access_token: 'othertoken').to_json }
    end

    context 'with expired token' do
      let(:token) { super().merge(expires_in: -1) }

      it { is_expected.to_not eq token.to_json }
      it { is_expected.to eq token.merge(access_token: 'othertoken').to_json }
    end
  end
end
