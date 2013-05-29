class SessionsController < ApplicationController
  # session create is set to the callback url action so it gets the omniauth response
  def create
    # find the User by creating from omniauth details || finding them in the user database from a previous login
    user = User.from_omniauth(env[''])
    # set the user id in the session
    # redirect to the right page
  end
end
