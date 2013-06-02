class UsersController < ApplicationController
  def show
    @twitter_friends = User.twitter_friends(current_user.uid)
  end
end
