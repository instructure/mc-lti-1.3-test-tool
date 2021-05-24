class AddNrpsEndpointsToPlatform < ActiveRecord::Migration[5.2]
  def change
    add_column :platforms, :nrps_courses, :string
    add_column :platforms, :nrps_groups, :string
  end
end
