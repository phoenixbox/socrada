class AddAuthorizationsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :authorizations, :hstore
  end
end
