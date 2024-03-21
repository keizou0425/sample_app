require 'rails_helper'

RSpec.describe "Account activation", type: :system do
  before do
    driven_by(:rack_test)
  end

  scenario 'ユーザー登録直後はアカウントは有効化されていない' do
    visit root_path
    click_link 'Sign up now!'
    fill_in 'Name', with: 'ExamleUser'
    fill_in 'Email', with: "user@example.com"
    fill_in 'Password', with: 'password'
    fill_in 'Password confirmation', with: 'password'
    click_button 'Create my account'

    # rackではokだが、seleniumではng。しかし2秒sleepするとok
    expect(current_path).to eq root_path

    visit login_path
    fill_in 'Email', with: "user@example.com"
    fill_in 'Password', with: 'password'
    click_button 'Log in'

    expect(current_path).to eq root_path
    expect(page).to have_selector('.alert-warning')
    expect(page.body).to have_content('Account not activated. Check your email for the activation link')
  end
end
