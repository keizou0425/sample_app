FactoryBot.define do
  factory :micropost do
    sequence(:content) { |n| "micropost_#{n}"}
    association :user

    trait :most_recent_post do
      created_at { Time.zone.now }
    end

    trait :yestudy_post do
      created_at { 1.day.ago }
    end

    trait :before_yestudy_post do
      created_at { 2.days.ago }
    end
  end
end
