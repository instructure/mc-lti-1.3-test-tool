# frozen_string_literal: true

class ResultsController < ApplicationController
  include Concerns::AgsConcerns

  def show
    service_render service.get(show_params, params[:line_item_id], :results)
  end

  private

  def show_params
    params.permit(
      :limit,
      :user_id
    ).to_h
  end
end
