class RenameImageUrlToProfileImageUrl < ActiveRecord::Migration
  def change
    rename_column :users, :image_url, :profile_image_url
  end
end
