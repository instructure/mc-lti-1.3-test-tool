Rails.application.routes.draw do
  health_check_routes

  # launch endpoints
  post 'launch' => 'launch#launch'
  post 'login' => 'authentication#login'

  # configuration specific
  scope :config do
    get 'new' => 'config#new'
    post '' => 'config#create'
    get 'malformed' => 'config#malformed_config'
    put ':id' => 'config#update'
    get ':id' => 'config#json_config'
    scope ':id' do
      get 'edit' => 'config#edit'
      get 'client_id/:client_id' => 'config#client_id'
      get 'platform' => 'config#platform'
      get 'credential' => 'config#credential'
      get 'info' => 'config#credential_and_platform'
    end
  end

  get 'placements' => 'config#placements'
  get 'scopes' => 'config#scopes'

  # token control
  scope :tokens do
    get ':credential_id/clear' => 'authentication#clear_token'
    get ':credential_id' => 'authentication#view_token'
  end

  #### Platform interaction #####

  scope :platform do
    get 'token/:credential_id' => 'authentication#retrieve_access_token'
  end

  ## LTI Advantage ##

  # deeplinking
  post 'deep_linking_redirect' => 'deep_linking#redirect'

  # nrps
  scope :nrps do
    get 'new' => 'nrps#new'
    post 'retrieve' => 'nrps#retrieve'
  end

  # ags
  scope :ags do
    get 'new' => 'ags#new'
    resource :line_items, only: %i[show update create destroy]
    resource :scores, only: %i[create]
    resource :results, only: %i[show]
    resource :progress, only: %i[show], controller: 'progress'
  end

  # update developer key
  scope :developer_key do
    scope ':credential_id' do
      get 'update_public_jwk' => 'developer_key_update#update_jwk'
      resource :data_services, except: [:edit] do
        get 'event_types' => 'data_services#event_types', on: :member
      end
      get '/:context_type/:context_id/feature_flags/:feature' => 'feature_flags#show'
    end
  end

  # endpoint for canvas to get public jwk
  get 'credential_id/:credential_id/public_jwk' => 'developer_key_update#external_access_for_jwk'
end
