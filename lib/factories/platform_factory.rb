# frozen_string_literal: true

require 'openssl'

# rubocop:disable Metrics/ClassLength
module Factories
  class PlatformFactory
    def initialize(options = {})
      @opts = options
    end

    def create_new_platform
      platform = Platform.find_by platform_iss: opts[:platform_iss]
      return platform if platform.present? && !opts[:new_credential]
      create_platform_and_credentials_and_deployments(platform)
    end

    def create_new_credentials
      platform = if opts.key? :platform_iss
                   Platform.find_by! platform_iss: opts[:platform_iss]
                 else
                   Platform.find opts[:platform_id]
                 end
      create_credentials(platform)
    end

    private

    attr_reader :opts

    def platform_url
      @platform_url ||= begin
        u = platform_uri
        port = [80, 443].include?(u.port) || u.port.nil? ? '' : ":#{u.port}"
        # for testing purposes, return whatever platform_url is
        u.host.blank? ? opts[:platform_url] : "#{u.scheme}://#{u.host}#{port}"
      end
    end

    def platform_uri
      URI(
        opts[:platform_url] ||
        opts[:public_key_endpoint] ||
        opts[:grant_url] ||
        "https://#{SecureRandom.uuid}.example.com"
      )
    end

    def authentication_redirect_endpoint
      @authentication_redirect_endpoint ||= "#{ensure_valid_scheme_and_host_only platform_url}/api/" \
        "lti/authorize_redirect"
    end

    def public_key_endpoint
      "#{ensure_valid_scheme_and_host_only platform_url}/api/lti/security/jwks"
    end

    def grant_url
      "#{ensure_valid_scheme_and_host_only platform_url}/login/oauth2/token"
    end

    def nrps_courses_endpoint
      "#{ensure_valid_scheme_and_host_only platform_url}/api/lti/courses/:context_id/names_and_roles"
    end

    def nrps_groups_endpoint
      "#{ensure_valid_scheme_and_host_only platform_url}/api/lti/groups/:context_id/names_and_roles"
    end

    def ags_endpoint
      "#{ensure_valid_scheme_and_host_only platform_url}/api/lti/courses/:context_id/line_items"
    end

    def data_services_endpoint
      "#{ensure_valid_scheme_and_host_only platform_url}/api/lti/accounts/:context_id/data_services"
    end

    def feature_flags_endpoint
      "#{ensure_valid_scheme_and_host_only platform_url}/api/lti/:context_type/:context_id/feature_flags/:feature"
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/PerceivedComplexity
    # rubocop:disable Metrics/CyclomaticComplexity
    def create_platform
      Platform.create!(
        platform_iss: opts[:platform_iss] || ensure_valid_scheme_and_host_only(platform_url),
        platform_guid: opts[:platform_guid] || SecureRandom.uuid,
        public_key_endpoint: opts[:public_key_endpoint] || public_key_endpoint,
        grant_url: opts[:grant_url] || grant_url,
        authentication_redirect_endpoint: opts[:authentication_redirect_endpoint] || authentication_redirect_endpoint,
        nrps_courses: opts[:nrps_courses] || nrps_courses_endpoint,
        nrps_groups: opts[:nrps_groups] || nrps_groups_endpoint,
        ags_url: opts[:ags_url] || ags_endpoint,
        data_services_url: opts[:data_services_url] || data_services_endpoint,
        feature_flags_url: opts[:feature_flags_url] || feature_flags_endpoint
      )
    end
    # rubocop:enable Metrics/PerceivedComplexity
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/AbcSize

    def create_platform_and_credentials_and_deployments(platform = nil)
      platform = create_platform if platform.blank?
      create_credentials(platform) unless opts[:no_populate]
      platform
    end

    def create_credentials(platform)
      c = create_credential(platform)
      create_deployments_and_contexts_and_resources(c) unless opts[:no_populate]
      c
    end

    def create_credential(platform)
      c = create_credential_from_platform(platform)
      if opts[:save_public_key] && !opts[:private_key]
        c.public_key = private_key.public_key.to_jwk(alg: :RS256, use: 'sig').to_h
      end
      c.save!
      c
    end

    def create_credential_from_platform(platform)
      pkey = opts[:private_key] || private_key
      platform.credentials.new(
        configuration: credential_config(pkey),
        oauth_client_id: opts[:oauth_client_id] || SecureRandom.uuid,
        private_key: pkey.to_jwk(alg: :RS256, use: 'sig').to_h
      )
    end

    def credential_config(pkey)
      (opts[:configuration] || {})
        .merge(
          public_jwk: pkey.public_key.to_jwk(alg: :RS256, use: 'sig').to_h
        )
    end

    def create_deployments_and_contexts_and_resources(credential)
      d = credential.deployments.create!(lti_deployment_id: SecureRandom.uuid)
      context = d.contexts.create!(context_id: SecureRandom.uuid)
      context.resources.create!(resource_id: SecureRandom.uuid)
    end

    def ensure_valid_scheme_and_host_only(uri)
      parsed_uri = URI(uri_with_default_scheme(uri))
      scheme = parsed_uri.scheme.nil? ? 'https' : default_to_https_if_not_valid_scheme(parsed_uri.scheme)
      host = parsed_uri.host
      port = [80, 443].include?(parsed_uri.port) || parsed_uri.port.nil? ? '' : ":#{parsed_uri.port}"
      "#{scheme}://#{host}#{port}"
    end

    def default_to_https_if_not_valid_scheme(scheme)
      %w[http https].include?(scheme) ? scheme : 'https'
    end

    def private_key
      @private_key ||= OpenSSL::PKey::RSA.new(2048)
    end

    def uri_with_default_scheme(uri)
      URI(uri).scheme.nil? ? "defaultscheme://#{uri}" : uri
    end
  end
end
# rubocop:enable Metrics/ClassLength
