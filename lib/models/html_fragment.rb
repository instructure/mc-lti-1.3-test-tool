# frozen_string_literal: true

module Models
  class HtmlFragment
    include ActiveModel::Model
    include ActiveModel::Serializers::JSON

    attr_accessor :type, :html, :title, :text

    def initialize(args = {})
      super
      self.type = 'html'
    end

    def attributes
      instance_values
    end
  end
end
