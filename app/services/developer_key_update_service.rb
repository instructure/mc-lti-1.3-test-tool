# frozen_string_literal: true

class DeveloperKeyUpdateService
  def initialize(url, access_token)
    @url = url
    @access_token = access_token
  end

  def put(query = {})
    request = prepare_request
    request = request.merge(body: { developer_key: { public_jwk: query } }.to_json)
    @response = HTTParty.put(@url, request)
    result
  end

  def success?
    @response&.success?
  end

  private

  attr_reader :access_token

  def prepare_request
    token = access_token['access_token']
    {
      headers: {
        'Content-Type' => 'application/json',
        'Authorization' => "Bearer #{token}"
      }
    }
  end

  def result
    success? ? JSON.parse(@response.body.presence || '{"type": "Success"}') : @response.body
  end
end
