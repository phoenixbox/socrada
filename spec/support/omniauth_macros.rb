module OmniauthMacros
  def mock_auth_hash
    OmniAuth.config.mock_auth[:twitter] = {
      'provider' => 'twitter',
      'uid' => '123545',
      'info' => {
        'nickname' => 'mockuser',
        'image' => 'mock_user_thumbnail_url',
        'nav_image'=> 'mock_user_twitter-picture'
      },
      'credentials' => {
        'token' => 'mock_token',
        'secret' => 'mock_secret'
      }
    }
  end

  def invalid_mock_auth_hash
    OmniAuth.config.mock_auth[:twitter] = :invalid_credentials
  end
end