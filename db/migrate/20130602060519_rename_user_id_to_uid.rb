class RenameUserIdToUid < ActiveRecord::Migration
  def change
    rename_column :twitter_relationships, :user_id, :uid
  end
end
