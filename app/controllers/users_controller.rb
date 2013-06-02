class UsersController < ApplicationController
  def show
    @friends = User.get_friends(current_user.screen_name, current_user)
  end
end
