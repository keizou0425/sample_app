require 'rails_helper'

RSpec.describe "Users search", type: :system do
  before do
    driven_by(:rack_test)
  end

  let(:alice) { create(:user, :alice) }

  before do
    10.times do |i|
      if i == 0
        FactoryBot.create(:user, name: 'tolice')
      else
        FactoryBot.create(:user)
      end
    end
  end

  scenario 'ユーザー名で検索できる' do
    visit login_path
    fill_in 'Email', with: alice.email
    fill_in 'Password', with: "password"
    click_button 'Log in'

    visit users_path
    expect(page).to have_selector('form.user_search')
    expect(all('ul.users>li').count).to eq 11

    fill_in 'Search by name', with: 'alice'
    click_button 'Search'
    expect(page.title).to eq 'Result | Ruby on Rails Tutorial Sample App'
    expect(all('ul.users>li').count).to eq 1
    expect(page).to have_link(alice.name, href: user_path(alice))
  end

  scenario '全方一致' do
    visit login_path
    fill_in 'Email', with: alice.email
    fill_in 'Password', with: "password"
    click_button 'Log in'

    visit users_path
    expect(page).to have_selector('form.user_search')
    expect(all('ul.users>li').count).to eq 11

    fill_in 'Search by name', with: 'al'
    click_button 'Search'
    expect(page.title).to eq 'Result | Ruby on Rails Tutorial Sample App'
    expect(all('ul.users>li').count).to eq 1
    expect(page).to have_link(alice.name, href: user_path(alice))
  end

  scenario '後方一致' do
    visit login_path
    fill_in 'Email', with: alice.email
    fill_in 'Password', with: "password"
    click_button 'Log in'

    visit users_path
    expect(page).to have_selector('form.user_search')
    expect(all('ul.users>li').count).to eq 11

    fill_in 'Search by name', with: 'ice'
    click_button 'Search'
    expect(page.title).to eq 'Result | Ruby on Rails Tutorial Sample App'
    expect(all('ul.users>li').count).to eq 2
    expect(page).to have_link(alice.name, href: user_path(alice))
  end

  scenario '検索に引っ掛からない時' do
    visit login_path
    fill_in 'Email', with: alice.email
    fill_in 'Password', with: "password"
    click_button 'Log in'

    visit users_path
    expect(page).to have_selector('form.user_search')
    expect(all('ul.users>li').count).to eq 11

    fill_in 'Search by name', with: 'foo'
    click_button 'Search'
    expect(page.title).to eq 'Result | Ruby on Rails Tutorial Sample App'
    expect(all('ul.users>li').count).to eq 0
    expect(page).to have_content 'Not found..'
    expect(page).not_to have_link(alice.name, href: user_path(alice))
  end
end
