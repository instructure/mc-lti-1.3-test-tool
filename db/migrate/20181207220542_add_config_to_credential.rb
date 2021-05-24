class AddConfigToCredential < ActiveRecord::Migration[5.2]
  def change
    add_column :credentials, :configuration, :jsonb
  end
end
