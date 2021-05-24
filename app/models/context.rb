# frozen_string_literal: true

class Context < ApplicationRecord
  belongs_to :deployment
  has_many :resources, dependent: :destroy

  validates :context_id, presence: true
end
