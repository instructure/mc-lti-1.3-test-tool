class CreateContextTable < ActiveRecord::Migration[5.2]
  def change
    create_table :contexts do |t|
      t.string :context_id
      t.jsonb :context_claim
      t.references :deployment, foreign_key: true
    end
  end
end
