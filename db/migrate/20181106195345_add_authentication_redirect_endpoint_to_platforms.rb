class AddAuthenticationRedirectEndpointToPlatforms < ActiveRecord::Migration[5.2]
  def change
    add_column :platforms, :authentication_redirect_endpoint, :string
  end
end
