FactoryGirl.define do
  factory :root_user, parent: :user do
    # vetted by self represents root user (first user ever)
    after(:create) do |user|
      user.update(vetted_by: user.id)
    end
  end

  factory :user do
    identity

    name  { Faker::Name.name }
    email { Faker::Internet.safe_email(name) }
    image_url { "http://example.com/image/#{SecureRandom.hex}" }
  end
end