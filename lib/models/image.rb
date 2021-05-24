# frozen_string_literal: true

module Models
  class Image < ContentItem
    attr_accessor :width, :height

    def initialize(args = {})
      self.type = 'image'
      super
    end
  end
end
