# frozen_string_literal: true

module Schemas
  class Base
    delegate :validate, :valid?, to: :schema_checker

    private

    def schema_checker
      @schema_checker ||= JSONSchemer.schema(schema)
    end

    def schema
      raise 'Abstract method'
    end
  end
end
