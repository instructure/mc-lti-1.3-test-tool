# frozen_string_literal: true

require 'spec_helper'

describe Token::ScopesCreator do
  describe '#create_scope_string' do
    subject { described_class.new(scopes).create_scope_string }

    let(:scopes) { [:ags_all] }
    let(:expected) do
      %w[
        https://purl.imsglobal.org/spec/lti-ags/scope/lineitem
        https://purl.imsglobal.org/spec/lti-ags/scope/result.readonly
        https://purl.imsglobal.org/spec/lti-ags/scope/score
      ].join(' ')
    end

    it { is_expected.to eq expected }

    context 'with defined rights_granted' do
      let(:scopes) { %i[line_item_readonly result] }
      let(:expected) do
        %w[
          https://purl.imsglobal.org/spec/lti-ags/scope/lineitem.readonly
          https://purl.imsglobal.org/spec/lti-ags/scope/result.readonly
        ].join(' ')
      end

      it { is_expected.to eq expected }

      context 'with rights_granted set to empty' do
        let(:scopes) { [] }
        let(:expected) { '' }

        it { is_expected.to eq expected }
      end
    end

    context 'with nrps defined as type' do
      let(:scopes) { [:nrps_all] }
      let(:expected) { 'https://purl.imsglobal.org/spec/lti-nrps/scope/contextmembership.readonly' }

      it { is_expected.to eq expected }

      context 'with defined rights_granted' do
        let(:scopes) { %i[contextmembership] }
        let(:expected) { 'https://purl.imsglobal.org/spec/lti-nrps/scope/contextmembership.readonly' }

        it { is_expected.to eq expected }

        context 'with rights_granted set to empty' do
          let(:scopes) { [] }
          let(:expected) { '' }

          it { is_expected.to eq expected }
        end
      end
    end

  end
end
