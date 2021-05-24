# frozen_string_literal: true

class Deployment < ApplicationRecord
  belongs_to :credential
  has_many :contexts, dependent: :destroy

  validates :lti_deployment_id, presence: true
end
