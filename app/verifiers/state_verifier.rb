# frozen_string_literal: true

class StateVerifier
  attr_reader :errors

  def initialize(nonce, state)
    @nonce = nonce
    @state = state
    @errors = []
  end

  def valid?
    validate_state
    @errors.blank?
  end

  private

  def validate_state
    @errors << 'State is invalid.' if StateStoreService.get_state(@nonce) != @state
  end
end
