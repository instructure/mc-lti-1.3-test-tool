class AddDataServicesUrl < ActiveRecord::Migration[5.2]
  def change
    add_column :platforms, :data_services_url, :string
  end
end
