class UsersController < ApplicationController
  respond_to :html, :json

  def show
    @twitter_friends = User.twitter_friends(current_user.uid) 
    @twitter_followers = User.twitter_followers(current_user.uid)
    @twitter_mutual = User.twitter_mutual(current_user.uid)
    @node = User.get_connections
    respond_with(@node)
  end
end
