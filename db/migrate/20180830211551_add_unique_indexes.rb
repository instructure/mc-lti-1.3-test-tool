class AddUniqueIndexes < ActiveRecord::Migration[5.2]
  def change
    add_index :platforms, :platform_iss, unique: true
    add_index :platforms, :platform_guid, unique: true
    add_index :credentials, %i[oauth_client_id platform_id], unique: true
  end
end
