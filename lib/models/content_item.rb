# frozen_string_literal: true

module Models
  class ContentItem
    include ActiveModel::Model
    include ActiveModel::Serializers::JSON

    attr_accessor :type,
      :url,
      :title,
      :text,
      :icon,
      :thumbnail

    def attributes
      instance_values
    end
  end
end
