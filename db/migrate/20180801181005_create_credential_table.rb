class CreateCredentialTable < ActiveRecord::Migration[5.2]
  def change
    create_table :credentials do |t|
      t.string :oauth_client_id
      t.jsonb :public_key
      t.references :platform, foreign_key:true
    end
  end
end
