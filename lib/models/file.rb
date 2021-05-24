# frozen_string_literal: true

module Models
  class File < ContentItem
    attr_accessor :mediaType, :expiresAt

    def initialize(args = {})
      self.type = 'file'
      super
    end
  end
end
