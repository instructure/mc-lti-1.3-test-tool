# frozen_string_literal: true

require 'spec_helper'

describe NrpsService do
  let(:url) { 'http://www.example.com' }
  let(:access_token) { 'token' }
  let(:id) { '1' }
  let(:create_id) { id }
  let(:type) { :line_item }
  let(:response) { double(success?: true, body: '{"hi": "there"}') }
  let(:query) { { help: 'no' } }

  context 'passes response body plain if not success' do
    let(:response) { double(success?: false, body: 'failed') }

    it do
      expected_url_called(url, :get, response, query: query)
      expect(described_class.new(url, access_token).parsed_get(query)).to eq 'failed'
    end
  end

  context 'results' do
    let(:type) { :results }

    it 'calls with expected query' do
      expected_url_called(url, :get, response, query: query)
      described_class.new(url, access_token).get(query)
    end
  end

  def expected_url_called(url, type, response, other_args = {})
    args = {
      headers: {
        "Content-Type" => "application/vnd.ims.lti-nrps.v2.membershipcontainer+json",
        "Authorization" => "Bearer "
      }
    }.merge(other_args)
    expect(HTTParty).to receive(type).with(url, args).and_return(response)
  end
end
