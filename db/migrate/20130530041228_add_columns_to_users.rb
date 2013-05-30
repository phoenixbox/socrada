class AddColumnsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :screen_name, :string
    add_column :users, :location, :string
    add_column :users, :followers_count, :integer
    add_column :users, :friends_count, :integer
    add_column :users, :statuses_count, :integer
  end
end
