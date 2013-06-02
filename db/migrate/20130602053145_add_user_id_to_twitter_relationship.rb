class AddUserIdToTwitterRelationship < ActiveRecord::Migration
  def change
    add_column :twitter_relationships, :user_id, :integer
  end
end
