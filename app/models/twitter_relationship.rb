class TwitterRelationship < ActiveRecord::Base
  attr_accessible  :uid, :friends, :followers, :mutual
  serialize :friends, ActiveRecord::Coders::Hstore
  serialize :followers, ActiveRecord::Coders::Hstore
  serialize :mutual, ActiveRecord::Coders::Hstore

  belongs_to :user

  def self.create_friends(twitter_friends, twitter_followers, twitter_mutual, user_uid)
    # find twitter_relationship by uid
    # if doesnt exist create it
    # if it does then update it
    create! do |twitter_relationship|
      twitter_relationship.uid = user_uid
      twitter_relationship.friends = twitter_friends
      twitter_relationship.followers = twitter_followers
      twitter_relationship.mutual = twitter_mutual
    end
  end
end