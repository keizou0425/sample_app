require 'rails_helper'

RSpec.describe "Users login", type: :system do
  before do
    driven_by(:rack_test)
  end

  let(:alice) { create(:user, :alice) }

  scenario 'ログイン情報が間違っている場合ログインできないこと' do
    visit login_path
    fill_in 'Email', with: ''
    fill_in 'Password', with: ''
    click_button 'Log in'

    expect(page).to have_content 'invalid email/password combination'
    expect(page).to have_selector '.alert-danger'
    expect(page).to have_link('Log in', href: login_path)

    # フラッシュメッセージが残っていないか確認している
    visit root_path
    expect(page).not_to have_selector '.alert-danger'
  end

  scenario 'ログイン情報が正しい場合、ログインできること' do
    visit login_path
    fill_in 'Email', with: alice.email
    fill_in 'Password', with: "password"
    click_button 'Log in'

    expect(page).not_to have_link('Log in', href: login_path)
    expect(page).to have_link('Log out', href: logout_path)
    expect(page).to have_link('Profile', href: user_path(alice))
  end

  scenario 'パスワードが間違っているとログインできないこと' do
    visit login_path
    fill_in 'Email', with: alice.email
    fill_in 'Password', with: ""
    click_button 'Log in'

    expect(page).to have_content 'invalid email/password combination'
    expect(page).to have_selector '.alert-danger'
    expect(page).to have_link('Log in', href: login_path)

    visit root_path
    expect(page).not_to have_selector '.alert-danger'
  end

  scenario 'ログアウトできること' do
    visit login_path
    fill_in 'Email', with: alice.email
    fill_in 'Password', with: "password"
    click_button 'Log in'

    expect(page).not_to have_link('Log in', href: login_path)
    expect(page).to have_link('Log out', href: logout_path)
    expect(page).to have_link('Profile', href: user_path(alice))

    click_link 'Log out'

    expect(page).to have_link('Log in', href: login_path)
    expect(page).not_to have_link('Log out', href: logout_path)
    expect(page).not_to have_link('Profile', href: user_path(alice))

    # 2 番目のウィンドウでログアウトをクリックするユーザーをシミュレートする(ログアウト後に再度ログアウトしてもバグらないことを確認)
    delete logout_path

    expect(page).to have_link('Log in', href: login_path)
    expect(page).not_to have_link('Log out', href: logout_path)
    expect(page).not_to have_link('Profile', href: user_path(alice))
  end
end
