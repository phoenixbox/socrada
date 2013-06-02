class User < ActiveRecord::Base
  attr_accessible :name, :provider, :uid
  serialize :authorizations, ActiveRecord::Coders::Hstore

  has_one :twitter_relationship

  # TODO: run again on further integrations
  def self.create_auth_methods
    %w[twitter_access_token twitter_access_secret].each do |key|
      attr_accessible key
      
      define_method(key) do
        authorizations && authorizations[key]
      end
    
      define_method("#{key}=") do |value|
        self.authorizations = (authorizations || {}).merge(key => value)
      end
    end
  end

  def self.from_omniauth(auth)
    where(auth.slice("provider", "uid")).first || create_from_omniauth(auth)
  end

  def self.create_from_omniauth(auth)
    info = auth["extra"]["raw_info"]
    create! do |user|
      user.uid = info["id"]
      user.name = info["name"]
      user.screen_name = info["screen_name"]
      user.profile_image_url = info["profile_image_url"]
      user.statuses_count = info["statuses_count"]
      user.followers_count = info["followers_count"]
      user.friends_count = info["friends_count"]
      user.authorizations = {
        twitter_access_token: auth["credentials"]["token"],
        twitter_access_secret: auth["credentials"]["secret"]}
      User.create_auth_methods
      # call to Twitter on user creation
      User.get_friends(user.screen_name, user)
      # get_twitter_followers(user.screen_name)
    end
  end

  def self.twitter_connect(user)
    Twitter.configure do |config|
      config.consumer_key = ENV["TWITTER_CONSUMER_KEY"]
      config.consumer_secret = ENV["TWITTER_CONSUMER_SECRET"]
      config.oauth_token = user["authorizations"][:twitter_access_token]
      config.oauth_token_secret = user["authorizations"][:twitter_access_secret]
    end
  end

  def self.get_twitter_friends(screen_name, user)
    User.twitter_connect(user)
    twitter = Twitter::Client.new
    friends = twitter.friends(screen_name)
    friends.collection.map{|friend|friend.screen_name}
  end

  def self.get_twitter_followers(screen_name, user)
    User.twitter_connect(user)
    twitter = Twitter::Client.new
    followers = twitter.followers(screen_name)
    followers.collection.map{|friend|friend.screen_name}
  end

  # need to take the results of these methods and store them in a relationship table
  # where the fields will be hstore

  def self.get_mutual(screen_name, user)
    followers = User.get_twitter_followers(screen_name, user)
    friends = User.get_twitter_friends(screen_name, user)
    followers & friends
  end

  def self.get_friends(screen_name, user)
    friends = User.get_twitter_friends(screen_name, user)
    mutuals = User.get_mutual(screen_name, user)
    twitter_friends = friends - mutuals
    TwitterRelationship.create_friends(twitter_friends, user.uid)
  end

  def self.get_followers(screen_name, user)
    followers = User.get_twitter_followers(screen_name, user)
    mutuals = User.get_mutual(screen_name, user)
    followers - mutuals
  end

  def self.twitter_friends(uid)
    twitter_relationship = TwitterRelationship.where("uid = #{uid}")
    twitter_relationship[0].friends.map{|k,v|k}
  end
end

# real_followers = User.get_followers("sdjrog")
