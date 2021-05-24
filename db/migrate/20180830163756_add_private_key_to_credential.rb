class AddPrivateKeyToCredential < ActiveRecord::Migration[5.2]
  def change
    add_column :credentials, :private_key, :jsonb
  end
end
