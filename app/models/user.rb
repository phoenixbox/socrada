class User < ActiveRecord::Base
  attr_accessible :name, :provider, :uid

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
      # call to Twitter for that user
      get_twitter_friends(user.screen_name)
      get_twitter_followers(user.screen_name)
    end
  end

  def self.twitter_connection
    Twitter.configure do |config|
      config.consumer_key = ENV["TWITTER_CONSUMER_KEY"]
      config.consumer_secret = ENV["TWITTER_CONSUMER_SECRET"]
      config.oauth_token = ENV["TWITTER_ACCESS_TOKEN"]
      config.oauth_token_secret = ENV["TWITTER_ACCESS_SECRET"]
    end
  end

  def self.get_twitter_friends(screen_name)
    User.twitter_connection
    twitter = Twitter::Client.new
    friends = twitter.friends(screen_name)
    friends.collection.map{|friend|friend.screen_name}
  end

  def self.get_twitter_followers(screen_name)
    User.twitter_connection
    twitter = Twitter::Client.new
    followers = twitter.followers(screen_name)
    followers.collection.map{|friend|friend.screen_name}
  end

  def self.get_mutual(screen_name)
    User.get_twitter_followers(screen_name) & User.get_twitter_friends(screen_name)
  end

  def self.get_friends(screen_name)
    User.get_twitter_friends(screen_name) - User.get_mutual(screen_name)
  end

  def self.get_followers(screen_name)
    User.get_twitter_followers(screen_name) - User.get_mutual(screen_name)
  end
end

# real_followers = User.get_followers("sdjrog")
