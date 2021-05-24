# frozen_string_literal: true

class DataServicesController < ApplicationController
  include Concerns::AdvantageConcerns

  before_action :load_credential

  def new() end

  def show
    service_render service.get(id, query)
  end

  def update
    service_render service.update(id, create_or_update_body)
  end

  def create
    service_render service.create(create_or_update_body)
  end

  def destroy
    service_render service.destroy(id)
  end

  def event_types
    service_render service.event_types(params[:message_type])
  end

  private

  def service
    @service ||= DataServicesService.new(platform.data_services_endpoint(params[:context_id]), fetch_access_token)
  end

  def create_or_update_body
    params.permit(
      :ContextId,
      :ContextType,
      :EventTypes,
      :Format,
      :TransportMetadata,
      :TransportType
    ).to_h
  end

  def query
    {}
  end
end
