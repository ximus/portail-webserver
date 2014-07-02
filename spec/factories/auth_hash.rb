FactoryGirl.define do
  factory :omniauth_hash do
    initialize_with do
      {
        'provider' => 'developertestprovider',
        'uid' => '123545',
        'user_info' => {
          'name' => 'mockuser',
          'image' => 'mock_user_thumbnail_url'
        },
        'credentials' => {
          'token' => 'mock_token',
          'secret' => 'mock_secret'
        }
      }
    end
  end
end