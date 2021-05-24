# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session

  class InvalidParameterValue < StandardError
  end

  rescue_from JSON::JWS::VerificationFailed do |e|
    error_render(e, :unauthorized)
  end

  rescue_from Concerns::AccessToken::InvalidAccessTokenRequest do |e|
    error_render(OpenStruct.new(message: JSON.parse(e.message)), :bad_request)
  end

  rescue_from InvalidParameterValue do |e|
    error_render(e, :bad_request)
  end

  def error_render(error, status)
    render json: { error: error.message }, status: status
  end
end
