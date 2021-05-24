class CreatePlatform < ActiveRecord::Migration[5.2]
  def change
    create_table :platforms do |t|
      t.string :platform_iss
      t.string :platform_guid
      t.string :public_key_endpoint
      t.jsonb :platform_claim
    end
  end
end
