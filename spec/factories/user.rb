FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "rails_#{n}"}
    sequence(:email) { |n| "rails_#{n}@example.com"}
    password { "password" }

    trait :admin_user do
      admin { true }
    end
  end
end
