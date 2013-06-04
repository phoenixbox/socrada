class ApplicationController < ActionController::Base
  before_filter :set_current_user

  protect_from_forgery

  def set_current_user
    User.current_user = current_user
  end

  private
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  helper_method :current_user
end