# frozen_string_literal: true

require 'spec_helper'

describe AgsService do
  let(:url) { 'http://www.example.com' }
  let(:access_token) { 'token' }
  let(:id) { '1' }
  let(:type) { :line_item }
  let(:response) { double(success?: true, body: '{"hi": "there"}') }
  let(:query) { { help: 'no' } }

  shared_examples 'passes response body plain if not success' do
    let(:response) { double(success?: false, body: 'failed') }

    it do
      expected_url_called(expected_url(url, type, id), :get, response, query: query)
      expect(described_class.new(url, access_token).get(query, id, type)).to eq 'failed'
    end
  end

  context 'line_item' do
    it 'calls with expected query' do
      expected_url_called(expected_url(url, type, id), :get, response, query: query)
      described_class.new(url, access_token).get(query, id, type)
    end

    it 'calls with expected PUT body' do
      expected_url_called(expected_url(url, type, id), :put, response, body: query.to_json)
      described_class.new(url, access_token).update(id, query)
    end

    context 'create' do
      let(:id) { nil }

      it 'calls with expected POST body' do
        expected_url_called(expected_url(url, type, id), :post, response, body: query.to_json)
        described_class.new(url, access_token).create(query, type, id)
      end
    end

    it 'calls with expected DELETE body' do
      expected_url_called(expected_url(url, type, id), :delete, response)
      described_class.new(url, access_token).destroy(id)
    end

    it_behaves_like 'passes response body plain if not success'
  end

  context 'scores' do
    let(:type) { :scores }

    it 'calls with expected POST body' do
      expected_url_called(expected_url(url, type, id), :post, response, body: query.to_json)
      described_class.new(url, access_token).create(query, type, id)
    end

    it_behaves_like 'passes response body plain if not success'
  end

  context 'results' do
    let(:type) { :results }

    it 'calls with expected query' do
      expected_url_called(expected_url(url, type, id), :get, response, query: query)
      described_class.new(url, access_token).get(query, id, type)
    end

    it_behaves_like 'passes response body plain if not success'
  end

  def expected_url(url, type, id = nil)
    u = id.nil? ? url : "#{url}/#{id}"
    case type
    when :scores
      "#{u}/scores"
    when :results
      "#{u}/results"
    else
      u
    end
  end

  def expected_url_called(url, type, response, other_args = {})
    args = {
      headers: { "Content-Type" => "application/json", "Authorization" => "Bearer " }
    }.merge(other_args)
    expect(HTTParty).to receive(type).with(url, args).and_return(response)
  end
end
