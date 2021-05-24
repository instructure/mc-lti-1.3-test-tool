# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
module Schemas
  class Config < Base
    SCHEMA = {
      'type' => 'object',
      'required' => %w[title description target_link_uri oidc_initiation_url],
      'properties' => {
        'title' => {
          'type' => 'string',
          'description' => 'the title of the tool'
        },
        'description' => {
          'type' => 'string',
          'description' => 'the description of the tool'
        },
        'target_link_uri' => {
          'type' => 'string',
          'description' => 'the url for launching of the tool',
          'format' => 'uri',
          'pattern' => '^(https?)://'
        },
        'oidc_initiation_url' => {
          'type' => 'string',
          'description' => 'the url for oidc initiation',
          'format' => 'uri',
          'pattern' => '^(https?)://'
        },
        'custom_fields' => {
          'type' => 'object',
          'additionalProperties' => {
            'type' => 'string'
          }
        },
        'scopes' => {
          'type' => 'array',
          'items' => {
            'type' => 'string'
          }
        },
        'public_jwk' => {
          'type' => 'object',
          'required' => %w[kty e n kid],
          'properties' => {
            'kty' => {
              'type' => 'string',
              'enum' => ['RSA']
            },
            'e' => {
              'type' => 'string',
              'enum' => ['AQAB']
            },
            'n' => {
              'type' => 'string'
            },
            'kid' => {
              'type' => 'string'
            }
          }
        },
        'extensions' => {
          'type' => 'array',
          'items' => {
            'type' => 'object',
            'properties' => {
              'platform' => {
                'type' => 'string'
              },
              'privacy_level' => {
                'type' => 'string',
                'enum' => %w[anonymous email_only name_only public]
              },
              'domain' => {
                'type' => 'string',
                'format' => 'uri',
                'pattern' => '^(https?)://'
              },
              'tool_id' => {
                'type' => 'string'
              },
              'assignment_points_possible' => {
                'type' => 'number'
              },
              'settings' => {
                'type' => 'object',
                'properties' => {
                  'icon_url' => {
                    'type' => 'string',
                    'format' => 'uri',
                    'pattern' => '^(https?)://'
                  },
                  'selection_height' => {
                    'type' => 'number'
                  },
                  'selection_width' => {
                    'type' => 'number'
                  },
                  'text' => {
                    'type' => 'string'
                  },
                  "placements" => {
                    "type" => "array",
                    "items" => {
                      "type" => "object",
                      "required" => [
                        "placement"
                      ].freeze,
                      "properties" => {
                        "placement" => {
                          "type" => "string",
                          "enum" => %w[
                            account_navigation
                            similarity_detection
                            assignment_edit
                            assignment_menu
                            assignment_selection
                            assignment_view
                            collaboration
                            course_assignments_menu
                            course_home_sub_navigation
                            course_navigation
                            course_settings_sub_navigation
                            discussion_topic_menu
                            editor_button
                            file_menu
                            global_navigation
                            homework_submission
                            link_selection
                            migration_selection
                            module_menu
                            post_grades
                            quiz_menu
                            resource_selection
                            tool_configuration
                            user_navigation
                            wiki_page_menu
                          ].freeze
                        }.freeze,
                        "target_link_uri" => {
                          "type" => "string"
                        }.freeze,
                        "text" => {
                          "type" => "string"
                        }.freeze,
                        "icon_url" => {
                          "type" => "string"
                        }.freeze,
                        "message_type" => {
                          "type" => "string",
                          "enum" => %w[
                            LtiDeepLinkingRequest
                            LtiResourceLinkRequest
                          ].freeze
                        }.freeze,
                        "canvas_icon_class": {
                          "type" => "string",
                          "enum" => [
                            "icon-lti"
                          ].freeze
                        }.freeze,
                        "selection_width" => {
                          "type" => "number"
                        }.freeze,
                        "selection_height" => {
                          "type" => "number"
                        }.freeze
                      }.freeze
                    }.freeze
                  }
                }
              }
            }
          }
        }
      }
    }.freeze

    def schema
      SCHEMA
    end
  end
end
# rubocop:enable Metrics/ClassLength
