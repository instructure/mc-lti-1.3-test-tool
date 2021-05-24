# frozen_string_literal: true

require 'token/jwt_creator'
require 'token/scopes_creator'

JWT_OPTIONS = %i[platform_url message_type version exp iat].freeze
ACCESS_TOKEN_OPTIONS = %i[platform_iss client_id credential_id scopes].freeze

namespace :jwt do
  desc "creates a jwk from options (options include #{JWT_OPTIONS.join(',')}). Will create a " \
       "Platform instance where all connected models are filled. Use this to test that the " \
       "tool is working as expected and for local debugging."
  task :create_jwt, JWT_OPTIONS => :environment do |_, args|
    out = { use_local_jwks: 'true' }
    out[:issued_at_minutes_ago] = ENV['iat'] if ENV.key?('iat')
    File.open(Rails.root.join('config', 'local_jwt.yml'), 'w') { |f| f.write out.to_yaml }
    opts = args.to_h
    puts Token::JwtCreator.create_jws_from_platform(opts.with_indifferent_access)
  end

  desc "retrieve an access token from the platform. Options include #{ACCESS_TOKEN_OPTIONS.join(',')}. " \
       "If you pass in credential_id, it should be the id of the Credential model. A client_id passed in " \
       "will be used to look up first, then followed by the credential_id. If none, will use first credential " \
       "of platform. You may also request scopes by entering a string in the format " \
       "<scope>,<scope>... where scope is one of #{Token::ScopesCreator::GROUPED_OPTIONS.keys.join(',')}"
  task :access_token, ACCESS_TOKEN_OPTIONS => :environment do |_, args|
    opts = args.to_h
    puts Token::JwtCreator.retrieve_access_token_from_platform(opts.with_indifferent_access)
  end
end
