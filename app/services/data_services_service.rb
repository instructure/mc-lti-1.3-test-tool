# frozen_string_literal: true

class DataServicesService
  def initialize(url, access_token)
    @url = url
    @access_token = access_token
  end

  def get(id, query = {})
    endpoint = id.present? ? url(id) : @url
    @response = HTTParty.get(endpoint, prepare_request.merge(query: compact(query)))
    result
  end

  def update(id, body)
    @response = HTTParty.put(url(id), prepare_request.merge(body: transform(body).to_json))
    result
  end

  def create(body)
    @response = HTTParty.post(@url, prepare_request.merge(body: transform(body).to_json))
    result
  end

  def destroy(id)
    @response = HTTParty.delete(url(id), prepare_request)
    result
  end

  def event_types(query = 'live-event')
    @response = HTTParty.get(
      "#{@url}/event_types",
      prepare_request.merge(query: { message_type: query })
    )
    result
  end

  def success?
    @response&.success?
  end

  private

  attr_reader :access_token

  def url(id)
    "#{@url}/#{id}"
  end

  def prepare_request
    {
      headers: {
        'Content-Type' => 'application/json',
        'Authorization' => "Bearer #{access_token['access_token']}"
      }
    }
  end

  def transform(body)
    body.merge(
      EventTypes: body[:EventTypes].split(',').map(&:strip),
      TransportMetadata: { Url: body[:TransportMetadata] }
    )
  end

  def compact(hsh)
    hsh.delete_if { |_, value| value.blank? }
  end

  def result
    success? ? JSON.parse(@response.body.presence || '{"type": "Success"}') : @response.body
  end
end
