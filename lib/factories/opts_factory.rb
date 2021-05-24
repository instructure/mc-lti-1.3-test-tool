# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
module Factories
  class OptsFactory
    BASE_PLACEMENTS = {
      wiki_page_menu: ' ',
      user_navigation: ' ',
      tool_configuration: ' ',
      similarity_detection: ' ',
      quiz_menu: ' ',
      post_grades: ' ',
      module_menu: ' ',
      migration_selection: ' ',
      link_selection: ' ',
      homework_submission: ' ',
      global_navigation: ' ',
      file_menu: ' ',
      editor_button: ' ',
      discussion_topic_menu: ' ',
      course_settings_sub_navigation: ' ',
      course_navigation: ' ',
      course_home_sub_navigation: ' ',
      course_assignments_menu: ' ',
      collaboration: ' ',
      assignment_selection: ' ',
      assignment_menu: ' ',
      account_navigation: ' '
    }.freeze
    DEEP_LINKING_PLACEMENTS = %w[
      assignment_selection
      collaboration
      editor_button
      homework_submission
      link_selection
      migration_selection
    ].freeze
    RESOURCE_LINK_MESSAGE_TYPE = 'LtiResourceLinkRequest'
    DEEP_LINKING_MESSAGE_TYPE = 'LtiDeepLinkingRequest'

    attr_accessor(:params, :base_url)
    def initialize(params, base_url)
      @params = params
      @base_url = base_url
    end

    def create_opts
      platform_opts.merge(configuration: generate_json)
    end

    def generate_json
      title = param_or_default(:title, "LTI 1.3 #{SecureRandom.hex(4)}")
      config = base_config(title)
      requested_placements.each { |placement| add_config(config, placement, title) }
      config[:custom_fields] = custom_fields if params[:custom_fields].present?
      config
    end

    def platform_opts
      opts = params.permit(
        :platform_url,
        :grant_url,
        :public_key_endpoint,
        :authentication_redirect_endpoint,
        :platform_guid,
        :nrps_courses,
        :nrps_groups,
        :ags_url,
        :data_services_url,
        :feature_flags_url
      )
      opts.merge!(save_public_key: true, new_credential: true, platform_iss: params.require(:iss))
      opts.to_h.delete_if { |_, v| v.blank? }
    end

    def param_or_default(param, default)
      params.permit(param)[param].presence || default
    end

    def requested_placements
      params[:placements].presence || ['course_navigation']
    end

    def add_config(config, placement, title)
      return if BASE_PLACEMENTS[placement.to_sym].nil?
      icon_url = param_or_default(:icon_url, 'https://static.thenounproject.com/png/131630-200.png')
      config[:extensions].first[:settings][:placements] << self.class.generate_placement_config(
        placement, title, base_url, icon_url
      )
    end

    # rubocop:disable Layout/LineLength
    def self.generate_placement_config(
      placement, title, base_url = 'http://localhost:3000', icon_url = 'https://static.thenounproject.com/png/131630-200.png'
    )
      message_type = DEEP_LINKING_PLACEMENTS.include?(placement) ? DEEP_LINKING_MESSAGE_TYPE : RESOURCE_LINK_MESSAGE_TYPE
      {
        message_type: message_type,
        placement: placement,
        canvas_icon_class: 'icon-lti',
        icon_url: icon_url,
        text: title,
        target_link_uri: base_url + "/launch?placement=#{placement}",
        enabled: true
      }
    end
    # rubocop:enable Layout/LineLength

    def custom_fields
      params[:custom_fields].split(',').each_with_object({}) do |field, memo|
        parts = field.split('=')
        memo[parts[0]] = parts[1]
      end
    end

    # rubocop:disable Metrics/MethodLength
    def base_config(title)
      {
        title: title,
        description: param_or_default(:description, '1.3 Test Tool'),
        oidc_initiation_url: base_url + '/login',
        target_link_uri: base_url + '/launch',
        extensions: [
          {
            platform: 'canvas.instructure.com',
            privacy_level: 'public',
            tool_id: title,
            domain: base_url,
            settings: {
              icon_url: param_or_default(:icon_url, 'https://static.thenounproject.com/png/131630-200.png'),
              selection_height: param_or_default(:height, 500),
              selection_width: param_or_default(:width, 500),
              text: "#{title} Extension text",
              placements: []
            }
          }
        ],
        scopes: Token::ScopesCreator.new((params[:scopes] || []).map(&:to_sym)).scopes
      }
    end
    # rubocop:enable Metrics/MethodLength

    def self.base_placements
      BASE_PLACEMENTS
    end
  end
end
# rubocop:enable Metrics/ClassLength
