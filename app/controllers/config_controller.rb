# frozen_string_literal: true

# rubocop:disable Layout/LineLength
class ConfigController < ApplicationController
  before_action :load_credential, only: %i[
    edit update client_id platform credential credential_and_platform json_config
  ]

  def new
    @placements = Factories::OptsFactory.base_placements.keys.each_with_object([]) { |p, memo| memo << [p.to_s.humanize, p] }
    @scopes = Token::ScopesCreator::GROUPED_OPTIONS.keys.each_with_object([]) { |p, memo| memo << [p.to_s.humanize, p] }
  end

  def edit
    setup_edit
  end

  def update
    @credential.update_config!(params.to_unsafe_h)
    setup_edit
    render :edit
  end

  def create
    opts = Factories::OptsFactory.new(params, request.base_url).create_opts
    platform = Factories::PlatformFactory.new(opts).create_new_platform
    credential = platform.credentials.last
    credential.update! requested_scopes: params[:scopes]
    render(
      json: {
        platform: platform.as_json, credential: credential.as_json
      },
      status: :created
    )
  end

  def json_config
    render json: @credential.configuration
  end

  def malformed_config
    render json: params[:syntax_error] ? '{"tool" : {"hi": "a"}' : Factories::OptsFactory.new(params, request.base_url).generate_json.except(:public_jwk)
  end

  def placements
    render json: Factories::OptsFactory.base_placements
  end

  def scopes
    render json: {
      config_options: Token::ScopesCreator::GROUPED_OPTIONS,
      scopes: Token::ScopesCreator::ALL_SCOPES
    }
  end

  def client_id
    @credential.update!(oauth_client_id: params[:client_id])
    render json: @credential.as_json
  end

  def platform
    render json: { platform: @credential.platform.as_json }
  end

  def credential
    render json: { credential: @credential.as_json }
  end

  def credential_and_platform
    render json: {
      platform: @credential.platform.as_json,
      credential: @credential.as_json
    }
  end

  private

  def load_credential
    @credential = Credential.find(params[:id])
  end

  def setup_edit
    @placements = Factories::OptsFactory.base_placements.keys.index_with { |p| [p.to_s.humanize, p] }
    @config = OpenStruct.new @credential.configuration
    @credential.extract_placement_objects.each do |place|
      instance_variable_set("@#{place['placement']}", OpenStruct.new(place))
      @placements.delete(place['placement'].to_sym)
    end
    @placements = @placements.values
  end
end
# rubocop:enable Layout/LineLength
