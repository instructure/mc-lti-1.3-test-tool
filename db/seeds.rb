Factories::PlatformFactory.new(platform_url: 'https://platform.example.edu').create_new_platform

# this is the tool used to check specific tool placements
params = ActionController::Parameters.new({
  "iss" => "http://canvas.instructure.com",
  "platform_url" => "http://canvas",
  "placements" => ["account_navigation", "course_navigation", "global_navigation"],
  "scopes" => ["all"]
})

opts = Factories::OptsFactory.new(params, 'http://lti_1_3').create_opts
Factories::PlatformFactory.new(opts).create_new_platform

# this is the tool used to check all tool placements
all_placements = %w(wiki_page_menu user_navigation tool_configuration
                    similarity_detection quiz_menu post_grades module_menu
                    migration_selection link_selection homework_submission
                    global_navigation file_menu editor_button
                    discussion_topic_menu course_settings_sub_navigation
                    course_navigation course_home_sub_navigation
                    course_assignments_menu collaboration
                    assignment_selection assignment_menu account_navigation)

params = ActionController::Parameters.new({
  "iss" => "https://canvas.instructure.com",
  "platform_url" => "http://canvas",
  "placements" => all_placements,
  "scopes" => ["all"]
})

opts = Factories::OptsFactory.new(params, 'http://lti_1_3').create_opts
Factories::PlatformFactory.new(opts).create_new_platform
