class AddGrantUrlToPlatform < ActiveRecord::Migration[5.2]
  def change
    add_column :platforms, :grant_url, :string
  end
end
