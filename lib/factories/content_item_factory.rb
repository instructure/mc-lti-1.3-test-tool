# frozen_string_literal: true

module Factories
  class ContentItemFactory
    DEFAULTS = {
      url: 'https://www.brothers-brick.com/',
      title: 'Lti 1.3 Tool Title',
      text: 'Lti 1.3 Tool Text',
      icon: 'https://img.icons8.com/metro/1600/unicorn.png',
      thumbnail: 'https://via.placeholder.com/150?text=thumbnail'
    }.freeze

    class << self
      def create(params, content_type, host: '')
        send("create_#{content_type}_content_item", shared_initialization_props(params).merge(launch_host: host))
      end

      def create_link_content_item(args = {})
        Models::Link.new(
          arguments_or_defaults(args,
            embed: args[:embed],
            window: args[:window],
            iframe: args[:iframe])
        )
      end

      def create_lti_resource_link_content_item(args = {})
        Models::LtiResourceLink.new(
          arguments_or_defaults(args,
            url: "#{Rails.application.routes.url_helpers.launch_url(host: args[:launch_host])}?deep_linking=true",
            embed: args[:embed],
            window: args[:window],
            iframe: args[:iframe],
            lineItem: args[:lineItem],
            available: args[:available],
            custom: args[:custom])
        )
      end

      def create_image_content_item(args = {})
        Models::Image.new(
          arguments_or_defaults(args,
            width: args[:width] || 500,
            height: args[:height] || 500,
            url: args[:url] || DEFAULTS[:thumbnail])
        )
      end

      def create_html_fragment_content_item(args = {})
        Models::HtmlFragment.new(
          html: args[:html],
          title: args[:title],
          text: args[:text]
        )
      end

      def create_file_content_item(args = {})
        Models::File.new(
          arguments_or_defaults(args,
            title: args[:title],
            url: args[:url] || "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
            text: args[:text],
            mediaType: args[:mediaType] || "application/pdf",
            expiresAt: args[:expiresAt] || "2318-03-06T20:05:02Z")
        )
      end

      private

      def shared_initialization_props(params)
        {
          embed: hashed_props(params, :embed),
          window: hashed_props(params, :window),
          iframe: hashed_props(params, :iframe),
          thumbnail: params[:thumbnail],
          html: params[:html],
          custom: params[:custom].present? ? JSON.parse(params[:custom]) : nil,
          multiple_items_number: params[:multiple_items_number],
          url: params[:url],
          text: params[:text].presence
        }
      end

      def hashed_props(params, param)
        return {} unless params.key?(param)

        JSON.parse params[param].to_s
      rescue JSON::ParserError
        nil
      end

      # Pull value from argument list or use default.
      # Add in extra args, then apply multiple_items_number if any
      def arguments_or_defaults(args, extra_args)
        result = DEFAULTS.each_with_object({}) { |(k, v), h| h[k] = args[k] || v }
        result.merge! extra_args
        augment_args_with_multiple_items_number!(result, args[:multiple_items_number])
        result
      end

      def augment_args_with_multiple_items_number!(args, num)
        return unless num
        %i[url icon thumbnail].each do |url_field|
          args[url_field] = augment_url_with_number_param(args[url_field], num) if args[url_field]
        end
        args[:title] += " ##{num}" if args[:title]
        args[:text] += " ##{num}" if args[:text]
      end

      def augment_url_with_number_param(url, number)
        url + (url.include?('?') ? '&' : '?') + "number=#{number}"
      end
    end
  end
end
