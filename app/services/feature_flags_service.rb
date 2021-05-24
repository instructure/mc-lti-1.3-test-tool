# frozen_string_literal: true

class FeatureFlagsService
  def initialize(url, access_token)
    @url = url
    @access_token = access_token
  end

  def get
    @response = HTTParty.get(@url, prepare_request)
    result
  end

  def success?
    @response&.success?
  end

  private

  attr_reader :access_token

  def prepare_request
    {
      headers: {
        'Content-Type' => 'application/json',
        'Authorization' => "Bearer #{access_token['access_token']}"
      }
    }
  end

  def result
    success? ? JSON.parse(@response.body.presence || '{"type": "Success"}') : @response.body
  end
end
