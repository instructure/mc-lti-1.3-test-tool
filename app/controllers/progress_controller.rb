# frozen_string_literal: true

class ProgressController < ApplicationController
  include Concerns::AgsConcerns

  def show
    service_render service.get({}, params[:progress_id], :progress)
  end
end
