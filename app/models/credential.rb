# frozen_string_literal: true

class Credential < ApplicationRecord
  belongs_to :platform
  has_many :deployments, dependent: :destroy

  validates :oauth_client_id, presence: true
  validates :private_key, presence: true

  def extract_placements
    extract_placement_objects.map { |p| p['placement'] }.compact
  end

  def extract_placement_objects
    configuration.dig('extensions', 0, 'settings', 'placements')
  end

  def update_config!(params)
    configuration.merge(params[:config])
    placements = extract_placement_objects
    update_placements(placements, params)
    create_new_placements(placements, params)
    save!
  end

  private

  def base_url
    url = URI.parse(configuration['target_link_uri'])
    "#{url.scheme}://#{url.host}#{[80, 443].include?(url.port) ? '' : ":#{url.port}"}"
  end

  def update_placements(placements, params)
    placements&.each do |placement|
      placement.merge!(params[placement['placement']] || {})
    end
  end

  def create_new_placements(placements, params)
    params['placements']&.each do |placement|
      placements << Factories::OptsFactory.generate_placement_config(placement, configuration['title'], base_url)
    end
  end
end
