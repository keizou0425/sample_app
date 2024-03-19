require 'rails_helper'

RSpec.describe "Users index", type: :system do
  before do
    driven_by(:rack_test)
  end

  let(:alice) { create(:user, :alice) }
  let(:admin) { create(:user, :admin_user) }

  before do
    30.times do
      FactoryBot.create(:user)
    end
  end

  scenario 'ページネーションでユーザー一覧を表示' do
    visit login_path
    fill_in 'Email', with: alice.email
    fill_in 'Password', with: "password"
    click_button 'Log in'

    visit users_path
    expect(page).to have_selector('div.pagination')
    User.paginate(page: 1).each do |user|
      expect(page).to have_link(user.name, href: user_path(user))
    end
  end

  scenario '管理者としてログインするとユーザー一覧からユーザーを削除できる' do
    visit login_path
    fill_in 'Email', with: admin.email
    fill_in 'Password', with: "password"
    click_button 'Log in'

    visit users_path
    expect(page).to have_selector('div.pagination')

    User.paginate(page: 1).each do |user|
      expect(page).to have_link(user.name, href: user_path(user))
      unless user == admin
        expect(page).to have_link('delete', href: user_path(user))
      end
    end

    expect {
      first('a', text: 'delete' ).click
    }.to change { User.count }.by(-1)
  end

  scenario '非管理者でログインするとユーザー削除用のリンクが表示されていない' do
    visit login_path
    fill_in 'Email', with: alice.email
    fill_in 'Password', with: "password"
    click_button 'Log in'

    visit users_path
    expect(page).not_to have_link('delete')
  end

  scenario '有効化されたユーザーの一覧のみ表示される' do
    first = User.first
    first.toggle!(:activated)

    visit login_path
    fill_in 'Email', with: alice.email
    fill_in 'Password', with: "password"
    click_button 'Log in'
    visit users_path

    User.paginate(page: 1).each do |user|
      expect(page).not_to have_link(first.name, href: user_path(first))
    end
  end
end
