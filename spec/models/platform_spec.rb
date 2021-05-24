# frozen_string_literal: true

require 'spec_helper'

describe Platform do
  describe "validations" do
    it { is_expected.to have_many(:credentials) }

    it { is_expected.to validate_presence_of(:platform_iss) }
    it { is_expected.to validate_presence_of(:platform_guid) }
    it { is_expected.to validate_presence_of(:public_key_endpoint) }
    it { is_expected.to validate_presence_of(:authentication_redirect_endpoint) }

    it { is_expected.to_not allow_value('example.com').for(:platform_iss) }
    it { is_expected.to_not allow_value('example.com').for(:public_key_endpoint) }
    it { is_expected.to_not allow_value('example.com').for(:authentication_redirect_endpoint) }
    it { is_expected.to_not allow_value('example.com').for(:nrps_courses) }
    it { is_expected.to_not allow_value('example.com').for(:nrps_groups) }
    it { is_expected.to_not allow_value('example.com').for(:ags_url) }
    it { is_expected.to_not allow_value('a').for(:platform_iss) }
    it { is_expected.to_not allow_value('a').for(:public_key_endpoint) }
  end
end
