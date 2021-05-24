# frozen_string_literal: true

class AccessTokenStorageService
  class << self
    def set_access_token(iss, token, exp = 5.minutes)
      redis.set(iss, token.to_json, ex: exp)
      token
    end

    def get_access_token(iss)
      data = redis.get(iss)
      Rails.logger.info("AccessToken from redis: #{data}")
      redis.del(iss) and return if data.present? && data_expired?(data)
      JSON.parse(data) if data.present?
    end

    def clear_token(iss)
      redis.del(iss)
    end

    private

    def redis
      Redis.current
    end

    def data_expired?(data)
      JSON.parse(data)['expires_in'].seconds.from_now < Time.zone.now
    end
  end
end
