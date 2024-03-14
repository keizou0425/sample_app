FactoryBot.define do
  factory :relationship do
    follower_id { create(:user).id }
    followed_id { create(:user, :alice).id}
  end
end
