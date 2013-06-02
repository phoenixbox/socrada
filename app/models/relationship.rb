class TwitterRelationship < ActiveRecord::Base
  attr_accessible :followers, :friends, :mutual
  serialize :friends, ActiveRecord::Coders::Hstore

  belongs_to :user

  def self.create_friends(twitter_friends, user_id)
    create! do |twitter_relationship|
      twitter_relationship.user_id = user_id
      twitter_relationship.friends = twitter_friends
    end
  end
end
