class User < ActiveRecord::Base
  attr_accessible :name, :provider, :uid

  def self.from_omniauth(auth)
    where()
  end

  def self.create_from_omniauth(auth)
  end
end
