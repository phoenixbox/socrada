class UsersController < ApplicationController
  def show
    @twitter_friends = User.twitter_friends(current_user.uid) 
    @twitter_followers = User.twitter_followers(current_user.uid)
    @twitter_mutual = User.twitter_mutual(current_user.uid)
  end
end
