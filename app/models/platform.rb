# frozen_string_literal: true

class Platform < ApplicationRecord
  has_many :credentials, dependent: :destroy

  validates :platform_iss, presence: true
  validates :platform_guid, presence: true
  validates :public_key_endpoint, presence: true
  validates :authentication_redirect_endpoint, presence: true
  validates :grant_url, presence: true
  validate :validate_proper_platform_urls

  def nrps_context_url(context_type, context_id)
    send("nrps_#{context_type}".to_sym).gsub(/:context_id/, context_id.to_s)
  end

  def ags_endpoint(context_id)
    ags_url.gsub(/:context_id/, context_id.to_s)
  end

  def data_services_endpoint(context_id)
    data_services_url.gsub(/:context_id/, context_id.to_s)
  end

  def feature_flags_endpoint(context_type, context_id, feature)
    feature_flags_url
      .gsub(/:context_type/, context_type)
      .gsub(/:context_id/, context_id.to_s)
      .gsub(/:feature/, feature)
  end

  def update_jwk_endpoint
    parsed = URI(ags_url)
    "#{parsed.scheme}://#{parsed.host}/api/lti/developer_key/update_public_jwk"
  end

  private

  def validate_proper_platform_urls
    validate_scheme_and_host :platform_iss
    validate_scheme_and_host :public_key_endpoint
    validate_scheme_and_host :authentication_redirect_endpoint
    validate_scheme_and_host :nrps_courses
    validate_scheme_and_host :nrps_groups
    validate_scheme_and_host :ags_url
    validate_scheme_and_host :data_services_url
    validate_scheme_and_host :feature_flags_url
  end

  def validate_scheme_and_host(url_field)
    return if send(url_field).nil?
    run_scheme_and_host_validations url_field, URI(send(url_field))
  rescue ArgumentError => e
    errors.add(url_field, e.message)
  end

  def run_scheme_and_host_validations(url_field, parsed_uri)
    errors.add(url_field, 'Scheme cannot be blank') if parsed_uri.scheme.nil?
    errors.add(url_field, 'Scheme must be https or http') unless http_scheme?(parsed_uri.scheme)
  end

  def http_scheme?(scheme)
    %w[http https].include? scheme
  end
end
