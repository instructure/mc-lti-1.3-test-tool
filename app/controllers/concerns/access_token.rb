# frozen_string_literal: true

module Concerns
  module AccessToken
    extend ActiveSupport::Concern

    class InvalidAccessTokenRequest < StandardError
    end

    # rubocop:disable Metrics/BlockLength
    included do
      def fetch_access_token
        @token = AccessTokenStorageService.get_access_token(access_token_key)
        @token = retrieve_and_set_token if @token.nil?
        Rails.logger.info("Token in controller: #{@token}")
        @token
      end

      def load_credential
        @credential = Credential.find(params.require(:credential_id))
      end

      def access_token_key
        "#{credential.platform.platform_iss}#{credential.id}"
      end

      def retrieve_and_set_token
        token_response = grant_service.request_token
        Rails.logger.info("Token response from Canvas: #{token_response}")
        raise InvalidAccessTokenRequest, token_response.to_json unless token_response.key? 'access_token'
        AccessTokenStorageService.set_access_token(
          access_token_key,
          token_response,
          token_response['expires_in']
        )
      end

      def grant_service
        @grant_service ||= ClientCredentialsGrantService.new(platform.grant_url, credential, scopes)
      end

      def credential
        @credential ||= begin
          credential = Credential.find_by!(oauth_client_id: params[:client_id]) if params[:client_id]
          credential = Credential.find(params[:credential_id]) if params[:credential_id]
          credential || platform.credentials.take
        end
      end

      def platform
        @platform ||= @credential.present? ? @credential.platform : Platform.find_by!(platform_iss: params[:iss])
      end

      def scopes
        raise 'Abstract Method'
      end
    end
    # rubocop:enable Metrics/BlockLength
  end
end
