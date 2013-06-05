class User < ActiveRecord::Base

  attr_reader :user_node
  attr_accessible :name, :provider, :uid
  serialize :authorizations, ActiveRecord::Coders::Hstore

  has_one :twitter_relationship

  def self.current_user
    Thread.current[:current_user]
  end

  def self.current_user=(user)
    Thread.current[:current_user] = user
  end

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
      User.get_twitter_data(user.screen_name, user)
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

  def self.get_twitter_data(screen_name, user)
    twitter_friends = User.get_friends(screen_name, user)
    twitter_followers = User.get_followers(screen_name, user)
    twitter_mutual = User.get_mutual(screen_name, user)
    TwitterRelationship.create_twitter_data(twitter_friends, twitter_followers, twitter_mutual, user.uid)
  end

  def self.get_mutual(screen_name, user)
    followers = User.get_twitter_followers(screen_name, user)
    friends = User.get_twitter_friends(screen_name, user)
    @twitter_mutuals = followers & friends
  end

  def self.get_friends(screen_name, user)
    friends = User.get_twitter_friends(screen_name, user)
    mutuals = User.get_mutual(screen_name, user)
    @twitter_friends = friends - mutuals
  end

  def self.get_followers(screen_name, user)
    followers = User.get_twitter_followers(screen_name, user)
    mutuals = User.get_mutual(screen_name, user)
    @twitter_followers = followers - mutuals
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

  def self.twitter_friends(uid)
    twitter_relationship = TwitterRelationship.where("uid = #{uid}")
    twitter_relationship[0].friends.map{|k,v|k}
  end

  def self.twitter_followers(uid)
    twitter_relationship = TwitterRelationship.where("uid = #{uid}")
    twitter_relationship[0].followers.map{|k,v|k}
  end

  def self.twitter_mutual(uid)
    twitter_relationship = TwitterRelationship.where("uid = #{uid}")
    twitter_relationship[0].mutual.map{|k,v|k}
  end

  def cypher_all_nodes
    "START n=node(*) RETURN n"
  end

  def self.current_user_node
    screen_name = User.current_user["screen_name"]
    User.neo.get_node_index("users","name",screen_name)
  end

  def self.add_to_users_index(node)
    User.neo.add_node_to_index( "users",
                                node["data"].keys[0],
                                node["data"].values[0], 
                                node
                                )
  end

# REFACTOR

  def self.create_friends_nodes
    friends = @twitter_friends
    friends.each do |friend|
      friend_node = User.neo.create_node(:name=>friend)
      User.add_to_users_index(friend_node)
      User.neo.create_relationship("friends", @current_user_node, friend_node)
    end
  end

  def self.create_follower_nodes
    followers = @twitter_followers
    followers.each do |follower|
      follower_node = User.neo.create_node(:name=>follower)
      User.add_to_users_index(follower_node)
      User.neo.create_relationship("follower", follower_node, @current_user_node)
    end
  end

  def self.create_mutual_nodes
    mutuals = @twitter_mutuals
    mutuals.each do |mutual|
      mutual_node = User.neo.create_node(:name=>mutual)
      User.add_to_users_index(mutual_node)
      User.neo.create_relationship("mutual", @current_user_node, mutual_node)
      User.neo.create_relationship("mutual", mutual_node, @current_user_node)
    end
  end

  def self.create_indexes
    indexes = User.neo.list_node_indexes
    unless indexes
      User.neo.create_node_index("users")
    end
  end

  def self.create_graph
    binding.pry
    User.create_indexes
    node = User.current_user_node rescue nil
    if node.nil?
      @current_user_node = User.neo.create_node(:name=>User.current_user[:screen_name])
      User.add_to_users_index(@current_user_node)
      User.create_friends_nodes
      User.create_follower_nodes
      User.create_mutual_nodes
    else
      graph_exists = User.neo.get_node_properties(node)
      return if graph_exists && graph_exists['name']
    end
  end

  def self.neighbours
    {"order"         => "depth first",
     "uniqueness"    => "none",
     "return filter" => {"language" => "builtin", "name" => "all_but_start_node"},
     "depth"         => 1}
  end

  def self.node_id(node)
    case node
      when Hash
        node["self"].split('/').last
      when String
        node.split('/').last
      else
        node
    end
  end

  def self.get_properties(node)
    properties = "<ul>"
    node["data"].each_pair do |key, value|
        properties << "<li><b>#{key}:</b> #{value}</li>"
      end
    properties + "</ul>"
  end

  def self.get_connections
    User.create_graph
    node = User.current_user_node[0]
    connections = User.neo.traverse(node, "fullpath", User.neighbours)
    incoming = Hash.new{|h, k| h[k] = []}
    outgoing = Hash.new{|h, k| h[k] = []}
    nodes = Hash.new
    attributes = Array.new

    connections.each do |c|
       c["nodes"].each do |n|
         nodes[n["self"]] = n["data"]
       end
       rel = c["relationships"][0]

       if rel["end"] == node["self"]
         incoming["Incoming:#{rel["type"]}"] << {:values => nodes[rel["start"]].merge({:id => User.node_id(rel["start"]) }) }
       else
         outgoing["Outgoing:#{rel["type"]}"] << {:values => nodes[rel["end"]].merge({:id => User.node_id(rel["end"]) }) }
       end
    end

    incoming.merge(outgoing).each_pair do |key, value|
      attributes << {:id => key.split(':').last, :name => key, :values => value.collect{|v| v[:values]} }
    end

    attributes = [{"name" => "No Relationships","name" => "No Relationships","values" => [{"id" => node,"name" => "No Relationships "}]}] if attributes.empty?

    @node = {:details_html => "<h2>Neo ID: #{User.node_id(node)}</h2>\n<p class='summary'>\n#{User.get_properties(node)}</p>\n",
              :data => {:attributes => attributes, 
                        :name => node["data"]["name"],
                        :id => User.node_id(node)}
            }

    @node.to_json
  end

  def self.neo
    @neo = Neography::Rest.new(ENV['NEO4J_URL'] || "http://localhost:7474")
  end

end