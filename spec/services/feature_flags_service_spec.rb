# frozen_string_literal: true

require 'spec_helper'

describe FeatureFlagsService do
  let(:url) { 'http://www.example.com/api/lti/account/1/feature_flags/foo' }
  let(:access_token) { 'token' }
  let(:id) { '1' }
  let(:response) { double(success?: true, body: expected_body) }
  let(:expected_body) do
    {
      state: "on",
      feature: "studnet_planner"
    }.to_json
  end

  it 'makes a request to the Canvas feature flag endpoint' do
    expected_url_called(url, :get, response)
    described_class.new(url, access_token).get
  end

  def expected_url_called(url, type, response, other_args = {})
    args = {
      headers: { "Content-Type" => "application/json", "Authorization" => "Bearer " }
    }.merge(other_args)
    expect(HTTParty).to receive(type).with(url, args).and_return(response)
  end
end
