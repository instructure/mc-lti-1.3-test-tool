# frozen_string_literal: true

module Concerns
  module AgsConcerns
    extend ActiveSupport::Concern
    include AdvantageConcerns

    included do
      before_action :load_credential

      def service
        @service ||= AgsService.new(
          platform.ags_endpoint(params[:context_id]),
          fetch_access_token
        )
      end
    end
  end
end
