# frozen_string_literal: true

module Models
  class LtiResourceLink < Link
    attr_accessor :lineItem, :available, :custom

    def initialize(args = {})
      super
      self.type = 'ltiResourceLink'
    end
  end
end
