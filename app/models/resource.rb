# frozen_string_literal: true

class Resource < ApplicationRecord
  belongs_to :context

  validates :resource_id, presence: true
end
