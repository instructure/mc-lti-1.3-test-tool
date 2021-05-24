class CreateUserTable < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :user_id
      t.jsonb :user_claim
      t.references :credential
    end
  end
end
