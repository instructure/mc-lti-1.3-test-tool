# frozen_string_literal: true

require 'spec_helper'

describe DeepLinkingController do
  let(:content_type) { 'link' }
  let(:return_url) { 'https://www.platform.com/success' }
  let(:message) { 'a message' }
  let(:error_message) { 'an error message' }
  let(:deployment_id) { SecureRandom.uuid }
  let(:decoded_jwt) { JSON::JWT.decode(assigns[:jwt], :skip_verification) }
  let(:content_items) { decoded_jwt['https://purl.imsglobal.org/spec/lti-dl/claim/content_items'] }
  let(:embed) { { html: '&lt;a href=""&gt;test&lt;/a&gt;' }.to_json }
  let(:thumbnail) { 'https:/www.test.com/my-image.png' }
  let(:multiple_items) { nil }
  let(:iframe) do
    {
      src: 'http://www.google.com',
      width: 500,
      height: 500
    }.to_json
  end
  let(:window) do
    {
      targetName: 'name',
      width: 600,
      height: 600,
      windowFeatures: 'menubar=yes,location=yes,resizable=yes,scrollbars=yes,status=yes'
    }.to_json
  end
  let_once(:credential) { Factories::PlatformFactory.new.create_new_platform.credentials.first }

  let(:extra_params) { {} }

  before do
    post(
      :redirect,
      params: {
        message: message,
        error_message: error_message,
        deployment_id: deployment_id,
        deep_link_return_url: return_url,
        content_type: content_type,
        multiple_items: multiple_items,
        embed: embed,
        iframe: iframe,
        window: window,
        thumbnail: thumbnail,
        aud: 'canvas',
        iss: credential.oauth_client_id
      }.merge(extra_params)
    )
  end

  describe '#redirect' do
    shared_examples_for 'redirect' do
      it 'sets the message' do
        expect(decoded_jwt['https://purl.imsglobal.org/spec/lti-dl/claim/msg']).to eq message
      end

      it 'sets the error message' do
        expect(decoded_jwt['https://purl.imsglobal.org/spec/lti-dl/claim/errormsg']).to eq error_message
      end

      it 'sets the deployment id' do
        expect(decoded_jwt['https://purl.imsglobal.org/spec/lti/claim/deployment_id']).to eq deployment_id
      end

      it 'sets the correct deep link return url' do
        expect(assigns[:deep_link_return_url]).to eq return_url
      end
    end

    context 'when content type is "link"' do
      it 'creates a "link" content item' do
        expect(content_items.length).to eq(1)
        expect(content_items.first['type']).to eq 'link'
      end

      it 'sets the thumbnail' do
        expect(content_items.first['thumbnail']).to eq thumbnail
      end

      it 'sets the embed value' do
        expect(content_items.first['embed']).to eq JSON.parse(embed)
      end

      it 'sets the iframe value' do
        expect(content_items.first['iframe']).to eq JSON.parse(iframe)
      end

      it 'sets the window value' do
        expect(content_items.first['window']).to eq JSON.parse(window)
      end

      it_behaves_like 'redirect'
    end

    context 'when multiple_items is true' do
      let(:multiple_items) { 'true' }
      let(:content_type) { 'lti_resource_link' }

      it 'creates multiple content items with a number in their title' do
        expect(content_items.length).to eq(3)
        expect(content_items[0]['title']).to end_with(' #1')
        expect(content_items[2]['title']).to end_with(' #3')
        expect(content_items[0]['url']).to end_with('&number=1')
        expect(content_items[1]['url']).to end_with('&number=2')
      end
    end
  end
end
