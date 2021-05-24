# frozen_string_literal: true

class StateStoreService
  class << self
    def set_state(nonce, state)
      redis.set(nonce, state, ex: 5.minutes)
    end

    def get_state(nonce)
      redis.get(nonce)
    end

    private

    def redis
      Redis.current
    end
  end
end
