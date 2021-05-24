# frozen_string_literal: true

module ActiveRecordHelper
  def next_unused_id(model_class)
    max_id = model_class.maximum(:id) || 0
    max_id + 1
  end

  def model_name(described_controller)
    described_controller.controller_name.singularize
  end
end
