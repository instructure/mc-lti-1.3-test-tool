class AddAuthenticationRedirectOverride < ActiveRecord::Migration[5.2]
  def change
    add_column :credentials, :authentication_redirect_override, :string
  end
end
