# frozen_string_literal: true

module Concerns
  module AdvantageConcerns
    extend ActiveSupport::Concern
    include AccessToken

    included do
      def service_render(results)
        service.success? ? render(json: results) : render(html: results.html_safe) # rubocop:disable Rails/OutputSafety
      end

      def id
        params[:id]
      end

      def scopes
        credential.requested_scopes.map(&:to_sym)
      end
    end
  end
end
