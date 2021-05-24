# frozen_string_literal: true

class FeatureFlagsController < ApplicationController
  include Concerns::AdvantageConcerns

  before_action :load_credential

  def show
    service_render service.get
  end

  private

  def context_type
    params.require(:context_type)
  end

  def context_id
    params.require(:context_id)
  end

  def feature
    params.require(:feature)
  end

  def service
    @service ||= FeatureFlagsService.new(
      platform.feature_flags_endpoint(context_type, context_id, feature),
      fetch_access_token
    )
  end
end
