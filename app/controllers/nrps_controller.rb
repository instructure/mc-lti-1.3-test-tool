# frozen_string_literal: true

class NrpsController < ApplicationController
  include Concerns::AdvantageConcerns

  before_action :load_credential, only: [:retrieve]

  def new
    @platforms = Platform.all
  end

  def retrieve
    service_render service.parsed_get(query)
  end

  private

  def service
    @service ||= NrpsService.new(nrps_context_url, fetch_access_token)
  end

  def nrps_context_url
    @nrps_context_url ||= platform.nrps_context_url(
      params.require(:context_type), params.require(:context_id)
    )
  end

  def query
    params.permit(:rlid, :role)
  end
end
