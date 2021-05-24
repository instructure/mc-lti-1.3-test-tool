class CreateDeploymentTable < ActiveRecord::Migration[5.2]
  def change
    create_table :deployments do |t|
      t.string :lti_deployment_id
      t.references :credential, foreign_key: true
    end
  end
end
