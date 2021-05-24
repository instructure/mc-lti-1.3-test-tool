# frozen_string_literal: true

require 'spec_helper'

describe ConfigController do
  subject { response }

  let(:params) { { iss: 'https://canvas.instructure.com' } }
  let(:json) { JSON.parse(response.body.to_s).with_indifferent_access }

  shared_examples 'returns valid configuration' do
    it 'conforms to the expected schema' do
      expect(Schemas::Config.new.validate(configuration).to_a).to be_empty
    end

    it 'populates the target_link_uri correctly' do
      expect(configuration[:target_link_uri]).to eq('http://test.host/launch')
    end

    it 'populates the domain correctly' do
      expect(configuration[:extensions].first[:domain]).to eq('http://test.host')
    end
  end

  describe '#create' do
    let(:configuration) { json[:credential][:configuration] }

    before { post :create, params: params }

    it { is_expected.to have_http_status 201 }

    it_behaves_like 'returns valid configuration'

    context 'with invalid placements requested' do
      let(:params) { super().merge placements: 'course account_nav file_menu'.split }

      it 'does not include invalid placements' do
        expect(configuration[:extensions].first[:settings][:placements].find { |p| p[:placement] == 'course' }).to(
          be_nil
        )
        expect(configuration[:extensions].first[:settings][:placements].find { |p| p[:placement] == 'account_nav' }).to(
          be_nil
        )
        expect(configuration[:extensions].first[:settings][:placements].find { |p| p[:placement] == 'file_menu' })
          .to_not(be_nil)
      end
    end

    context 'with no placements requested' do
      Factories::OptsFactory.base_placements.keys.each do |placement|
        if placement == :course_navigation
          it "#{placement} returns a value" do
            expect(
              configuration[:extensions].first[:settings][:placements].any? { |p| p[:placement] == placement.to_s }
            ).to(
              eq true
            )
          end
        else
          it "#{placement} returns no value" do
            expect(
              configuration[:extensions].first[:settings][:placements].any? { |p| p[:placement] == placement.to_s }
            ).to(
              eq false
            )
          end
        end
      end
    end

    context 'with multiple placements requested' do
      let(:params) { super().merge placements: 'course_navigation account_navigation'.split }
      Factories::OptsFactory.base_placements.keys.each do |placement|
        if %i[course_navigation account_navigation].include? placement
          it "#{placement} returns a value" do
            expect(
              configuration[:extensions].first[:settings][:placements].any? { |p| p[:placement] == placement.to_s }
            ).to(eq true)
          end
        else
          it "#{placement} returns no value" do
            expect(
              configuration[:extensions].first[:settings][:placements].any? { |p| p[:placement] == placement.to_s }
            ).to(eq false)
          end
        end
      end
    end

    context 'with deep linking placements requested' do
      let(:params) { super().merge placements: ['editor_button'] }

      it 'sets the correct message type' do
        expect(configuration[:extensions].first.dig(:settings, :placements).find do |p|
          p['placement'] == 'editor_button'
        end['message_type']).to eq(
          'LtiDeepLinkingRequest'
        )
      end
    end
  end

  describe '#json_config' do
    let(:configuration) { json }

    before do
      post :create, params: { iss: 'https://canvas.instructure.com' }
      credential_json = JSON.parse(response.body.to_s).with_indifferent_access
      credential = Credential.find credential_json[:credential][:id]
      get :json_config, params: { id: credential.id }
    end

    it_behaves_like 'returns valid configuration'
  end

  describe '#placements' do
    before { get :placements }

    it { is_expected.to have_http_status 200 }

    it 'returns valid json' do
      expect { json }.to_not raise_error
    end
  end

  describe '#scopes' do
    before { get :scopes }

    it { is_expected.to have_http_status 200 }

    it 'returns valid json' do
      expect { json }.to_not raise_error
    end
  end
end
