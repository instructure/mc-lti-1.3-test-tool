# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_09_27_141738) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "contexts", force: :cascade do |t|
    t.string "context_id"
    t.jsonb "context_claim"
    t.bigint "deployment_id"
    t.index ["deployment_id"], name: "index_contexts_on_deployment_id"
  end

  create_table "contexts_users_roles", id: false, force: :cascade do |t|
    t.bigint "users_role_id", null: false
    t.bigint "context_id", null: false
    t.index ["context_id", "users_role_id"], name: "index_contexts_users_roles_on_context_id_and_users_role_id", unique: true
  end

  create_table "credentials", force: :cascade do |t|
    t.string "oauth_client_id"
    t.jsonb "public_key"
    t.bigint "platform_id"
    t.jsonb "private_key"
    t.jsonb "configuration"
    t.text "requested_scopes", default: [], array: true
    t.string "authentication_redirect_override"
    t.string "public_jwk_endpoint_override"
    t.index ["oauth_client_id", "platform_id"], name: "index_credentials_on_oauth_client_id_and_platform_id", unique: true
    t.index ["platform_id"], name: "index_credentials_on_platform_id"
  end

  create_table "deployments", force: :cascade do |t|
    t.string "lti_deployment_id"
    t.bigint "credential_id"
    t.index ["credential_id"], name: "index_deployments_on_credential_id"
  end

  create_table "platforms", force: :cascade do |t|
    t.string "platform_iss"
    t.string "platform_guid"
    t.string "public_key_endpoint"
    t.jsonb "platform_claim"
    t.string "grant_url"
    t.string "authentication_redirect_endpoint"
    t.string "nrps_courses"
    t.string "nrps_groups"
    t.string "ags_url"
    t.string "data_services_url"
    t.string "feature_flags_url"
    t.index ["platform_guid"], name: "index_platforms_on_platform_guid", unique: true
    t.index ["platform_iss"], name: "index_platforms_on_platform_iss", unique: true
  end

  create_table "resources", force: :cascade do |t|
    t.string "resource_id"
    t.jsonb "resource_link_claim"
    t.bigint "context_id"
    t.index ["context_id"], name: "index_resources_on_context_id"
  end

  create_table "user_roles", force: :cascade do |t|
    t.string "role"
    t.bigint "user_id"
    t.index ["user_id"], name: "index_user_roles_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "user_id"
    t.jsonb "user_claim"
    t.bigint "credential_id"
    t.index ["credential_id"], name: "index_users_on_credential_id"
  end

  add_foreign_key "contexts", "deployments"
  add_foreign_key "credentials", "platforms"
  add_foreign_key "deployments", "credentials"
  add_foreign_key "resources", "contexts"
end
