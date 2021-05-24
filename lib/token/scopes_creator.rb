# frozen_string_literal: true

module Token
  class ScopesCreator
    AGS_SCOPES = {
      %i[all ags_all line_item] => 'https://purl.imsglobal.org/spec/lti-ags/scope/lineitem',
      %i[line_item_readonly readonly] => 'https://purl.imsglobal.org/spec/lti-ags/scope/lineitem.readonly',
      %i[all ags_all result readonly] => 'https://purl.imsglobal.org/spec/lti-ags/scope/result.readonly',
      %i[all ags_all score] => 'https://purl.imsglobal.org/spec/lti-ags/scope/score',
      %i[all feature_flags_all feature_flag] => 'https://canvas.instructure.com/lti/feature_flags/scope/show',
      %i[all progress_all progress] => 'https://canvas.instructure.com/lti-ags/progress/scope/show'
    }.freeze
    NRPS_SCOPES = {
      %i[all nrps_all readonly contextmembership contextmembershipreadonly] =>
        'https://purl.imsglobal.org/spec/lti-nrps/scope/contextmembership.readonly'
    }.freeze
    PUBLIC_JWK_SCOPES = {
      %i[all public_jwk] => "https://canvas.instructure.com/lti/public_jwk/scope/update"
    }.freeze
    DATA_SERVICES_SCOPES = {
      %i[all data_services_all data_services_create] => "https://canvas.instructure.com/lti/data_services/scope/create",
      %i[all data_services_all data_services_update] => "https://canvas.instructure.com/lti/data_services/scope/update",
      %i[all data_services_all data_services_list] => "https://canvas.instructure.com/lti/data_services/scope/list",
      %i[all data_services_all data_services_destroy] =>
        "https://canvas.instructure.com/lti/data_services/scope/destroy",
      %i[all data_services_all data_services_show] => "https://canvas.instructure.com/lti/data_services/scope/show",
      %i[all data_services_all data_services_event_types] =>
        "https://canvas.instructure.com/lti/data_services/scope/list_event_types"
    }.freeze
    COMBINED_SCOPES = AGS_SCOPES.merge(NRPS_SCOPES).merge(PUBLIC_JWK_SCOPES).merge(DATA_SERVICES_SCOPES).freeze
    ALL_SCOPES = COMBINED_SCOPES.keys.each_with_object({}) do |key, memo|
      scope = AGS_SCOPES[key] || NRPS_SCOPES[key] || PUBLIC_JWK_SCOPES[key] || DATA_SERVICES_SCOPES[key]
      memo[scope] = []
      key.each { |sub_key| memo[scope] << sub_key }
      memo[scope].freeze
    end.freeze
    GROUPED_OPTIONS = ALL_SCOPES.keys.each_with_object({}) do |key, memo|
      options = ALL_SCOPES[key]
      options.each { |opt| memo.key?(opt) ? memo[opt] << key : memo[opt] = [key] }
    end.freeze

    attr_reader :scopes

    def initialize(requested_scopes = [])
      @scopes = []
      return if requested_scopes.empty?

      filter_keys(requested_scopes, COMBINED_SCOPES).each { |key| @scopes << COMBINED_SCOPES[key] }
    end

    def create_scope_string
      @scopes.join(' ')
    end

    def self.parse_scopes(scope_string)
      return [] if scope_string.nil?
      scope_string.split(',').map(&:to_sym)
    end

    private

    def filter_keys(rights_granted, scope_keys)
      to_include = {}
      rights_granted.each do |right|
        keys = scope_keys.keys.select { |key| key.include? right } || []
        keys.each do |key|
          to_include[key] = true
        end
      end
      to_include.keys
    end
  end
end
