class AddRequestedScopesToCredential < ActiveRecord::Migration[5.2]
  def change
    add_column :credentials, :requested_scopes, :text, array: true, default: []
  end
end
