class User < ActiveRecord::Base
  attr_accessible :name, :provider, :uid

  def self.from_omniauth(auth)
    where(auth.slice("provider", "uid")).first || create_from_omniauth(auth)
  end

  def self.create_from_omniauth(auth)
    binding.pry
    info = auth["extra"]["raw_info"]
    create! do |user|
      user.uid = info["id"]
      user.name = info["name"]
      user.screen_name = info["screen_name"]
      user.profile_image_url = info["profile_image_url"]
      user.statuses_count = info["statuses_count"]
      user.followers_count = info["followers_count"]
      user.friends_count = info["friends_count"]
    end
  end
end
