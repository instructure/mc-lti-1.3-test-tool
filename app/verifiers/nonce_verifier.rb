# frozen_string_literal: true

class NonceVerifier
  # rubocop:disable Style/ClassVars
  @@nonces = Set.new

  def self.verify_nonce(nonce)
    return false if @@nonces.include? nonce

    @@nonces.add(nonce) && true
  end
  # rubocop:enable Style/ClassVars
end
