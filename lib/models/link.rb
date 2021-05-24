# frozen_string_literal: true

module Models
  class Link < ContentItem
    attr_accessor :embed, :window, :iframe

    def initialize(args = {})
      self.type = 'link'
      super
    end
  end
end
