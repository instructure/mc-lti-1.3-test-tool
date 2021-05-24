class AddFeatureFlagsUrlToPlatform < ActiveRecord::Migration[5.2]
  def change
    add_column :platforms, :feature_flags_url, :string
  end
end
