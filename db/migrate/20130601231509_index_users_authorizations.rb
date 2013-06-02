class IndexUsersAuthorizations < ActiveRecord::Migration
  def up
    execute "CREATE INDEX users_authorizations ON users USING GIN(authorizations)"
  end

  def down
    execute "DROP INDEX users_authorizations"
  end
end
