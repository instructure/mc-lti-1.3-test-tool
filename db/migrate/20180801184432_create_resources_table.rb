class CreateResourcesTable < ActiveRecord::Migration[5.2]
  def change
    create_table :resources do |t|
      t.string :resource_id
      t.jsonb :resource_link_claim
      t.references :context, foreign_key: true
    end
  end
end
