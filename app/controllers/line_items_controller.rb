# frozen_string_literal: true

class LineItemsController < ApplicationController
  include Concerns::AgsConcerns

  def show
    service_render service.get(query, id)
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

  private

  def create_or_update_body
    params.permit(
      :scoreMaximum,
      :label,
      :resourceId,
      :resourceLinkId,
      :tag,
      :startDateTime,
      :endDateTime,
      :submissionType,
      :externalToolUrl
    ).to_h
  end

  def query
    params.permit(:resource_link_id, :resource_id, :tag, :limit).to_h
  end
end
