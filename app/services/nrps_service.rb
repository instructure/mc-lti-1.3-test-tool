# frozen_string_literal: true

class NrpsService
  def initialize(url, access_token)
    @url = url
    @access_token = access_token
  end

  def get(query = {})
    HTTParty.get(@url, prepare_request.merge(query: compact(query)))
  end

  def success?
    @response&.success?
  end

  def parsed_get(query = {})
    @response = get(query)
    success? ? JSON.parse(@response.body) : @response.body
  end

  private

  attr_reader :access_token

  def prepare_request
    {
      headers: {
        'Content-Type' => 'application/vnd.ims.lti-nrps.v2.membershipcontainer+json',
        'Authorization' => "Bearer #{access_token['access_token']}"
      }
    }
  end

  def compact(hsh)
    hsh.delete_if { |_, value| value.blank? }
  end
end
