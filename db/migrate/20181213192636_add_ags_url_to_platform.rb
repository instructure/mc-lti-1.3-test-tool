class AddAgsUrlToPlatform < ActiveRecord::Migration[5.2]
  def change
    add_column :platforms, :ags_url, :string
  end
end
