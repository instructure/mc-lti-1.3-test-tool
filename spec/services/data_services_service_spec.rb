# frozen_string_literal: true

require 'spec_helper'

describe DataServicesService do
  let(:url) { 'http://www.example.com' }
  let(:access_token) { 'token' }
  let(:id) { '1' }
  let(:response) { double(success?: true, body: expected_body) }
  let(:query) do
    {
      EventTypes: 'a,b',
      TransportMetadata: 'sqs.docker'
    }
  end
  let(:expected_body) do
    {
      EventTypes: %w[a b],
      TransportMetadata: { Url: 'sqs.docker' }
    }.to_json
  end

  context 'passes response body plain if not success' do
    let(:response) { double(success?: false, body: 'failed') }

    it do
      expected_url_called(url, :get, response, query: query)
      expect(described_class.new(url, access_token).get(nil, query)).to eq 'failed'
    end
  end

  it 'calls with expected query' do
    expected_url_called(url, :get, response, query: query)
    described_class.new(url, access_token).get(nil, query)
  end

  it 'calls list with expected query' do
    expected_url_called("#{url}/#{id}", :get, response, query: query)
    described_class.new(url, access_token).get(id, query)
  end

  it 'calls with expected PUT body' do
    expected_url_called("#{url}/#{id}", :put, response, body: expected_body)
    described_class.new(url, access_token).update(id, query)
  end

  it 'calls with expected POST body' do
    expected_url_called(url, :post, response, body: expected_body)
    described_class.new(url, access_token).create(query)
  end

  it 'calls with expected DELETE body' do
    expected_url_called("#{url}/#{id}", :delete, response)
    described_class.new(url, access_token).destroy(id)
  end

  it 'calls with event_types with expected params' do
    expected_url_called(
      "#{url}/event_types",
      :get,
      response,
      query: { message_type: 'live-event' }
    )
    described_class.new(url, access_token).event_types
  end

  def expected_url_called(url, type, response, other_args = {})
    args = {
      headers: { "Content-Type" => "application/json", "Authorization" => "Bearer " }
    }.merge(other_args)
    expect(HTTParty).to receive(type).with(url, args).and_return(response)
  end
end
