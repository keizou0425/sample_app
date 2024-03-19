require 'rails_helper'

RSpec.describe "Following", type: :system do
  let(:user) { create(:user) }
  let(:alice) { create(:user, :alice) }
  let(:bob) { create(:user, :bob) }

  before do
    driven_by(:rack_test)
  end

  scenario '自分がフォローしている人の一覧ページ' do
    [alice, bob].each do |friend|
      user.follow(friend)
      friend.follow(user)
    end

    user_following_count = user.followings.count

    visit login_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: "password"
    click_button 'Log in'

    visit following_user_path(user)

    expect(user_following_count).to eq 2
    expect(page).to have_content user_following_count.to_s
    user.followings.each do |u|
      expect(page).to have_link(u.name, href: user_path(u))
    end
  end

  scenario '自分をフォローしている人の一覧ページ' do
    [alice, bob].each do |friend|
      user.follow(friend)
      friend.follow(user)
    end

    user_followers_count = user.followers.count

    visit login_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: "password"
    click_button 'Log in'

    visit followers_user_path(user)

    expect(user_followers_count).to eq 2
    expect(page).to have_content user_followers_count.to_s
    user.followers.each do |u|
      expect(page).to have_link(u.name, href: user_path(u))
    end
  end

  scenario 'フォロー' do
    visit login_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: "password"
    click_button 'Log in'

    visit user_path(alice)
    expect {
      click_button 'Follow'
    }.to change { Relationship.count }.by(1)
    expect(user.following?(alice)).to be_truthy
  end

  scenario 'アンフォロー' do
    user.follow(alice)

    visit login_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: "password"
    click_button 'Log in'

    visit user_path(alice)
    expect {
      click_button 'Unfollow'
    }.to change { Relationship.count }.by(-1)
    expect(user.following?(alice)).to be_falsey
  end
end
