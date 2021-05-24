class CreateUserRoleInContextJoinTable < ActiveRecord::Migration[5.2]
  def change
    create_join_table :users_roles, :contexts do |t|
      t.index [:context_id, :users_role_id], unique: true
    end
  end
end
