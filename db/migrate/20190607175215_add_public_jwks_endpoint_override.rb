class AddPublicJwksEndpointOverride < ActiveRecord::Migration[5.2]
  def change
    add_column :credentials, :public_jwk_endpoint_override, :string
  end
end
