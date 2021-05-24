# frozen_string_literal: true

module Token
  JWKS = {
    "jwk-past.json" => JSON::JWK.new(
      "kty" => "RSA",
      "e" => "AQAB",
      "n" => "uX1MpfEMQCBUMcj0sBYI-iFaG5Nodp3C6OlN8uY60fa5zSBd83-iIL3n_qzZ8VCluuTLfB7rrV_tiX727XIEqQ",
      "kid" => "2018-05-18T22:33:20Z",
      "d" => "pYwR64x-LYFtA13iHIIeEvfPTws50ZutyGfpHN-kIZz3k-xVpun2Hgu0hVKZMxcZJ9DkG8UZPqD-zTDbCmCyLQ",
      "p" => "6OQ2bi_oY5fE9KfQOcxkmNhxDnIKObKb6TVYqOOz2JM",
      "q" => "y-UBef95njOrqMAxJH1QPds3ltYWr8QgGgccmcATH1M",
      "dp" => "Ol_xkL7rZgNFt_lURRiJYpJmDDPjgkDVuafIeFTS4Ic",
      "dq" => "RtzDY5wXr5TzrwWEztLCpYzfyAuF_PZj1cfs976apsM",
      "qi" => "XA5wnwIrwe5MwXpaBijZsGhKJoypZProt47aVCtWtPE"
    ),
    "jwk-present.json" => JSON::JWK.new(
      "kty" => "RSA",
      "e" => "AQAB",
      "n" => "uX1MpfEMQCBUMcj0sBYI-iFaG5Nodp3C6OlN8uY60fa5zSBd83-iIL3n_qzZ8VCluuTLfB7rrV_tiX727XIEqQ",
      "kid" => "2018-06-18T22:33:20Z",
      "d" => "pYwR64x-LYFtA13iHIIeEvfPTws50ZutyGfpHN-kIZz3k-xVpun2Hgu0hVKZMxcZJ9DkG8UZPqD-zTDbCmCyLQ",
      "p" => "6OQ2bi_oY5fE9KfQOcxkmNhxDnIKObKb6TVYqOOz2JM",
      "q" => "y-UBef95njOrqMAxJH1QPds3ltYWr8QgGgccmcATH1M",
      "dp" => "Ol_xkL7rZgNFt_lURRiJYpJmDDPjgkDVuafIeFTS4Ic",
      "dq" => "RtzDY5wXr5TzrwWEztLCpYzfyAuF_PZj1cfs976apsM",
      "qi" => "XA5wnwIrwe5MwXpaBijZsGhKJoypZProt47aVCtWtPE"
    ),
    "jwk-future.json" => JSON::JWK.new(
      "kty" => "RSA",
      "e" => "AQAB",
      "n" => "uX1MpfEMQCBUMcj0sBYI-iFaG5Nodp3C6OlN8uY60fa5zSBd83-iIL3n_qzZ8VCluuTLfB7rrV_tiX727XIEqQ",
      "kid" => "2018-07-18T22:33:20Z",
      "d" => "pYwR64x-LYFtA13iHIIeEvfPTws50ZutyGfpHN-kIZz3k-xVpun2Hgu0hVKZMxcZJ9DkG8UZPqD-zTDbCmCyLQ",
      "p" => "6OQ2bi_oY5fE9KfQOcxkmNhxDnIKObKb6TVYqOOz2JM",
      "q" => "y-UBef95njOrqMAxJH1QPds3ltYWr8QgGgccmcATH1M",
      "dp" => "Ol_xkL7rZgNFt_lURRiJYpJmDDPjgkDVuafIeFTS4Ic",
      "dq" => "RtzDY5wXr5TzrwWEztLCpYzfyAuF_PZj1cfs976apsM",
      "qi" => "XA5wnwIrwe5MwXpaBijZsGhKJoypZProt47aVCtWtPE"
    )
  }.freeze

  # rubocop:disable Metrics/ClassLength
  class JwtCreator
    class << self
      def public_keyset
        Token::JWKS.values.map do |private_jwk|
          public_jwk = private_jwk.to_key.public_key.to_jwk
          public_jwk.merge(private_jwk.select { |k, _| %w[alg use kid].include?(k) })
        end
      end

      def create_jws_from_platform(opts = {})
        platform = retrieve_platform(opts) || Factories::PlatformFactory.new(opts).create_new_platform
        jwt = JSON::JWT.new(create_claims(platform: platform, **opts))
        jws = jwt.sign(JSON::JWK.new(Token::JWKS.values.sample(1).first), :RS256)
        jws.to_s
      end

      def retrieve_access_token_from_platform(opts = {})
        platform = retrieve_platform(opts)
        credential = retrieve_credential(platform, opts)
        ClientCredentialsGrantService.new(
          platform.grant_url, credential, Token::ScopesCreator.parse_scopes(opts[:scopes])
        ).request_token
      end

      private

      def retrieve_platform(opts)
        unless opts.key?(:platform_url) || opts.key?(:platform_iss)
          platform = Platform.first
          return platform if platform.present?
        end
        search_by = opts[:platform_iss] || opts[:platform_url]
        Platform.find_by(platform_iss: search_by)
      end

      def retrieve_credential(platform, opts)
        cred = platform.credentials.find_by(oauth_client_id: opts[:client_id]) if opts.key?(:client_id)
        if opts.key?(:credential_id) && cred.nil?
          cred = platform.credentials.find(opts[:credential_id])
        elsif cred.nil?
          cred = platform.credentials.first
        end
        cred
      end

      def create_claims(platform:, message_type: 'LtiResourceLinkRequest', version: '1.3.0', exp: 12, iat: 1)
        credential = platform.credentials.first
        deployment = credential.deployments.first
        context = deployment.contexts.first
        resource = context.resources.first
        claims = base_claims(platform, credential, exp, iat)
        claims.merge! additional_claims(deployment, context, resource, message_type, version)
      end

      def base_claims(platform, credential, exp, iat)
        security_claims(platform, credential, exp, iat)
          .merge!(platform_claim(platform))
          .merge!(user_claims(platform))
      end

      def additional_claims(deployment, context, resource, message_type, version)
        message_claims(deployment, message_type, version)
          .merge!(context_and_resource_claims(context, resource))
          .merge!(role_claims)
          .merge!(lis_and_custom_claims)
      end

      def security_claims(platform, credential, exp, iat)
        {
          iss: platform.platform_iss,
          sub: "a6d5c443-1f51-4783-ba1a-7686ffe3b54a",
          aud: [credential.oauth_client_id],
          exp: exp.minutes.from_now.to_i,
          iat: iat.minute.ago.to_i,
          azp: credential.oauth_client_id,
          nonce: SecureRandom.uuid
        }
      end

      def user_claims(platform)
        {
          name: "Ms Jane Marie Doe",
          given_name: "Jane",
          family_name: "Doe",
          middle_name: "Marie",
          picture: "#{platform.public_key_endpoint}/jane.jpg",
          email: "jane@#{platform.public_key_endpoint.split('//').last.split('/').first}",
          locale: "en-US"
        }
      end

      def message_claims(deployment, message_type, version)
        {
          "https://purl.imsglobal.org/spec/lti/claim/deployment_id": deployment.lti_deployment_id,
          "https://purl.imsglobal.org/spec/lti/claim/message_type": message_type,
          "https://purl.imsglobal.org/spec/lti/claim/version": version
        }
      end

      def role_claims
        {
          "https://purl.imsglobal.org/spec/lti/claim/roles": [
            "http://purl.imsglobal.org/vocab/lis/v2/institution/person#Student",
            "http://purl.imsglobal.org/vocab/lis/v2/membership#Learner",
            "http://purl.imsglobal.org/vocab/lis/v2/membership#Mentor"
          ],
          "https://purl.imsglobal.org/spec/lti/claim/role_scope_mentor": [
            "http://purl.imsglobal.org/vocab/lis/v2/institution/person#Administrator"
          ]
        }
      end

      # rubocop:disable Metrics/MethodLength
      def context_and_resource_claims(context, resource)
        {
          "https://purl.imsglobal.org/spec/lti/claim/context": {
            id: context.context_id,
            label: "ECON 1010",
            title: "Economics as a Social Science",
            type: ["http://purl.imsglobal.org/vocab/lis/v2/course#CourseOffering"]
          },
          "https://purl.imsglobal.org/spec/lti/claim/resource_link": {
            id: resource.resource_id,
            description: "Assignment to introduce who you are",
            title: "Introduction Assignment"
          }
        }
      end

      def platform_claim(platform)
        {
          "https://purl.imsglobal.org/spec/lti/claim/tool_platform": {
            guid: platform.platform_guid,
            contact_email: "support@#{platform.public_key_endpoint}",
            description: "An Example Tool Platform",
            name: "Example Tool Platform",
            url: platform.public_key_endpoint, # technically wrong, but oh well
            product_family_code: "ExamplePlatformVendor-Product",
            version: "1.0"
          },
          "https://purl.imsglobal.org/spec/lti/claim/launch_presentation": {
            document_target: "iframe",
            height: 320,
            width: 240,
            return_url: "#{platform.public_key_endpoint}/return"
          }
        }
      end

      def lis_and_custom_claims
        {
          "https://purl.imsglobal.org/spec/lti/claim/custom": {
            xstart: "2017-04-21T01:00:00Z",
            request_url: "https://tool.com/link/123"
          },
          "https://purl.imsglobal.org/spec/lti/claim/lis": {
            person_sourcedid: "example.edu:71ee7e42-f6d2-414a-80db-b69ac2defd4",
            course_offering_sourcedid: "example.edu:SI182-F16",
            course_section_sourcedid: "example.edu:SI182-001-F16"
          }
        }
      end
      # rubocop:enable Metrics/MethodLength
    end
    # rubocop:enable Metrics/ClassLength
  end
end
