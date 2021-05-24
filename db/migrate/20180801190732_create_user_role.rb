class CreateUserRole < ActiveRecord::Migration[5.2]
  def change
    create_table :user_roles do |t|
      t.string :role
      t.references :user
    end
  end
end
