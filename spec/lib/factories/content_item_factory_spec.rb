# frozen_string_literal: true

require 'spec_helper'

describe Factories::ContentItemFactory do
  let(:title) { 'A title' }
  let(:text) { 'some text' }
  let(:icon) { 'an icon' }
  let(:thumbnail) { 'a thumbnail' }
  let(:embed) { 'embed' }
  let(:window) { 'window' }
  let(:iframe) { 'iframe' }

  shared_examples_for 'link content item properties' do
    it 'uses the provided title' do
      expect(subject.title).to eq title
    end

    it 'uses the provided text' do
      expect(subject.text).to eq text
    end

    it 'uses the provided icon' do
      expect(subject.icon).to eq icon
    end

    it 'uses the provided thumbnail' do
      expect(subject.thumbnail).to eq thumbnail
    end

    it 'uses the provided embed' do
      expect(subject.embed).to eq embed
    end

    it 'uses the provided window' do
      expect(subject.window).to eq window
    end

    it 'uses the provided iframe' do
      expect(subject.iframe).to eq iframe
    end
  end

  shared_examples_for 'link content item defaults' do
    it 'uses the default title' do
      expect(subject.title).to eq Factories::ContentItemFactory::DEFAULTS[:title]
    end

    it 'uses the default text' do
      expect(subject.text).to eq Factories::ContentItemFactory::DEFAULTS[:text]
    end

    it 'uses the default icon' do
      expect(subject.icon).to eq Factories::ContentItemFactory::DEFAULTS[:icon]
    end

    it 'uses the default thumbnail' do
      expect(subject.thumbnail).to eq Factories::ContentItemFactory::DEFAULTS[:thumbnail]
    end
  end

  describe '#create_html_fragment_content_item' do
    subject { Factories::ContentItemFactory.create_html_fragment_content_item(params) }

    context 'when arguments are provided' do
      let(:params) do
        {
          html: '<a href="www.test.com">hello</a>',
          title: 'title',
          text: 'text'
        }
      end

      it 'sets the "html"' do
        expect(subject.html).to eq params[:html]
      end

      it 'sets the "title"' do
        expect(subject.title).to eq params[:title]
      end

      it 'sets the "text"' do
        expect(subject.text).to eq params[:text]
      end
    end
  end

  describe '#create_file_content_item' do
    subject { Factories::ContentItemFactory.create_file_content_item(params) }

    context 'when no arguments are provided' do
      let(:params) { {} }

      it 'sets the file url' do
        expect(subject.url).to eq "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf"
      end

      it 'sets the default media type' do
        expect(subject.mediaType).to eq "application/pdf"
      end

      it 'sets the default expiresAt' do
        expect(subject.expiresAt).to eq "2318-03-06T20:05:02Z"
      end

      it 'does not set the a default value to text' do
        expect(subject.text).to be_nil
      end
    end

    context 'when arguments are provided' do
      let(:params) do
        {
          mediaType: "img/jpeg",
          expiresAt: "2000-03-06T20:05:02Z",
          url: 'https://www.test.com/image',
          text: 'image.png'
        }
      end

      it 'sets the mediaType' do
        expect(subject.mediaType).to eq params[:mediaType]
      end

      it 'sets the expiresAt' do
        expect(subject.expiresAt).to eq params[:expiresAt]
      end

      it 'sets the url' do
        expect(subject.url).to eq params[:url]
      end

      it 'sets the text' do
        expect(subject.text).to eq params[:text]
      end
    end
  end

  describe '#create_image_content_item' do
    subject { Factories::ContentItemFactory.create_image_content_item(params) }

    context 'when no arguments are provided' do
      let(:params) { {} }

      it 'sets the image url' do
        expect(subject.url).to eq 'https://via.placeholder.com/150?text=thumbnail'
      end

      it 'sets the default width' do
        expect(subject.width).to eq 500
      end

      it 'sets the default height' do
        expect(subject.height).to eq 500
      end
    end

    context 'when arguments are provided' do
      let(:params) do
        {
          width: 100,
          height: 300,
          url: 'https://www.test.com/image'
        }
      end

      it 'sets the width' do
        expect(subject.width).to eq params[:width]
      end

      it 'sets the height' do
        expect(subject.height).to eq params[:height]
      end

      it 'sets the url' do
        expect(subject.url).to eq params[:url]
      end
    end
  end

  describe '#create_lti_resource_link_content_item' do
    let(:host) { 'test.com' }
    let(:available) do
      {
        startDateTime: Time.zone.now,
        endDateTime: Time.zone.now + 1.hour
      }
    end
    let(:lineItem) do
      {
        label: 'line item label',
        scoreMaximum: 23.3,
        resourceId: SecureRandom.uuid,
        tag: 'line item tag'
      }
    end
    let(:custom) { { foo: 'bar' } }

    subject { Factories::ContentItemFactory.create_lti_resource_link_content_item(params) }

    context 'when no arguments are provided' do
      let(:params) { { launch_host: host } }

      it 'uses the launch url' do
        expect(subject.url).to eq 'http://test.com/launch?deep_linking=true'
      end

      it_behaves_like 'link content item defaults'
    end

    context 'when arguments are provided' do
      let(:params) do
        {
          title: title,
          text: text,
          icon: icon,
          thumbnail: thumbnail,
          embed: embed,
          window: window,
          iframe: iframe,
          launch_host: host,
          available: available,
          lineItem: lineItem,
          custom: custom
        }
      end

      it 'uses the custom parameters' do
        expect(subject.custom).to eq custom
      end

      it 'uses the launch url' do
        expect(subject.url).to eq 'http://test.com/launch?deep_linking=true'
      end

      it 'sets the "available" property' do
        expect(subject.available).to eq available
      end

      it 'sets the "lineItem" property' do
        expect(subject.lineItem).to eq lineItem
      end

      it_behaves_like 'link content item properties'
    end
  end

  describe '#create_link_content_item' do
    subject { Factories::ContentItemFactory.create_link_content_item(params) }

    context 'when no arguments are provided' do
      let(:params) { {} }

      it 'uses the default url' do
        expect(subject.url).to eq Factories::ContentItemFactory::DEFAULTS[:url]
      end

      it_behaves_like 'link content item defaults'
    end

    context 'when arguments are provided' do
      let(:url) { 'http://www.test.com' }
      let(:params) do
        {
          url: url,
          title: title,
          text: text,
          icon: icon,
          thumbnail: thumbnail,
          embed: embed,
          window: window,
          iframe: iframe
        }
      end

      it 'uses the provided url' do
        expect(subject.url).to eq url
      end

      it_behaves_like 'link content item properties'
    end
  end

  describe '#create' do
    subject do
      described_class.create(
        { multiple_items_number: 3, thumbnail: 'http://foo.com/?x=1' },
        :lti_resource_link,
        host: 'myhost.com'
      )
    end

    it 'adds multiple_items_number onto all url-like and text-like fields' do
      expect(subject).to be_a(Models::LtiResourceLink)

      expect(subject.icon).to eq(Factories::ContentItemFactory::DEFAULTS[:icon] + '?number=3')
      expect(subject.thumbnail).to eq('http://foo.com/?x=1&number=3')
      expect(subject.url).to eq('http://myhost.com/launch?deep_linking=true&number=3')
      expect(subject.text).to eq('Lti 1.3 Tool Text #3')
      expect(subject.title).to eq('Lti 1.3 Tool Title #3')
    end
  end
end
