FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "rails_#{n}"}
    sequence(:email) { |n| "rails_#{n}@example.com"}
    password { "password" }
    activated { true }
    activated_at { Time.zone.now }

    after(:build) do |user|
      user.default_image_attache
    end

    trait :admin_user do
      admin { true }
    end

    trait :alice do
      name { "alice" }
      email { "alice@example.com"}
    end

    trait :bob do
      name { "bob" }
      email { "bob@example.com" }
    end

    trait :carol do
      name { "carol" }
      email { "carol@example.com" }
    end

    trait :dave do
      name { "dave" }
      email { "dave@example.com" }
    end

    trait :in_activated do
      activated { false }
      activated_at { nil }
    end

    trait :with_post do
      after(:create) { |user| create_list(:micropost, 50, user: user) }
    end
  end
end
