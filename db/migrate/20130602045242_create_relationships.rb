class CreateTwitterRelationships < ActiveRecord::Migration
  def change
    create_table :twitter_relationships do |t|
      t.hstore :friends
      t.hstore :followers
      t.hstore :mutual

      t.timestamps
    end
  end
end
