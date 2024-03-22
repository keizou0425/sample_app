require 'rails_helper'

RSpec.describe "Microposts search", type: :system do
  before do
    driven_by(:rack_test)
  end

  let(:alice) { create(:user, :alice) }
  let(:bob) { create(:user, :bob) }

  before do
    alice.microposts.create(content: 'this is alice')
    10.times do
      bob.microposts.create(content: 'this is bob')
    end
  end

  scenario 'キーワードで検索できる' do
    visit login_path
    fill_in 'Email', with: alice.email
    fill_in 'Password', with: "password"
    click_button 'Log in'

    visit root_path
    expect(page).to have_selector('form.micropost_search')

    fill_in 'Search microposts', with: 'alice'
    click_button 'Search'
    expect(page.title).to eq 'Result | Ruby on Rails Tutorial Sample App'
    expect(all('ul.microposts>li').count).to eq 1
    expect(page).to have_link(alice.name, href: user_path(alice))
  end

  scenario '全方一致' do
    visit login_path
    fill_in 'Email', with: alice.email
    fill_in 'Password', with: "password"
    click_button 'Log in'

    visit root_path
    expect(page).to have_selector('form.micropost_search')

    fill_in 'Search microposts', with: 'thi'
    click_button 'Search'
    expect(page.title).to eq 'Result | Ruby on Rails Tutorial Sample App'
    expect(all('ul.microposts>li').count).to eq 11
    expect(page).to have_link(alice.name, href: user_path(alice))
    expect(page).to have_link(bob.name, href: user_path(bob))
  end

  scenario '後方一致' do
    visit login_path
    fill_in 'Email', with: alice.email
    fill_in 'Password', with: "password"
    click_button 'Log in'

    visit root_path
    expect(page).to have_selector('form.micropost_search')

    fill_in 'Search microposts', with: 'lice'
    click_button 'Search'
    expect(page.title).to eq 'Result | Ruby on Rails Tutorial Sample App'
    expect(all('ul.microposts>li').count).to eq 1
    expect(page).to have_link(alice.name, href: user_path(alice))
  end

  scenario '検索に引っ掛からない時' do
    visit login_path
    fill_in 'Email', with: alice.email
    fill_in 'Password', with: "password"
    click_button 'Log in'

    visit root_path
    expect(page).to have_selector('form.micropost_search')

    fill_in 'Search microposts', with: 'are'
    click_button 'Search'
    expect(page.title).to eq 'Result | Ruby on Rails Tutorial Sample App'
    expect(all('ul.microposts>li').count).to eq 0
    expect(page).to have_content 'Not found..'
    expect(page).not_to have_link(alice.name, href: user_path(alice))
  end
end
