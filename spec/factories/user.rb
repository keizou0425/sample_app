FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "rails_#{n}"}
    sequence(:email) { |n| "rails_#{n}@example.com"}
    password { "password" }
    activated { true }
    activated_at { Time.zone.now }

    trait :admin_user do
      admin { true }
    end

    trait :alice do
      name { "alice" }
    end
  end
end
