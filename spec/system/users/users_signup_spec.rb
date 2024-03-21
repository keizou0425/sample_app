require 'rails_helper'

RSpec.describe "Users signup", type: :system do
  before do
    driven_by(:rack_test)
    ActionMailer::Base.deliveries.clear
  end

  scenario '登録情報に不備がある場合、ユーザー登録できない' do
    visit root_path
    expect {
      click_link 'Sign up now!'
      fill_in 'Name', with: ''
      fill_in 'Email', with: "user@invalid"
      fill_in 'Password', with: 'foo'
      fill_in 'Password confirmation', with: 'bar'
      click_button 'Create my account'
    }.not_to change { User.count }

    expect(page).not_to have_selector('.alert-info')
    expect(page).to have_content 'The form contains 4 errors.'
    expect(ActionMailer::Base.deliveries.size).to eq 0
  end

  scenario '登録情報に不備がない場合、ユーザー登録できる' do
    visit root_path
    expect {
      click_link 'Sign up now!'
      fill_in 'Name', with: 'ExamleUser'
      fill_in 'Email', with: "user@example.com"
      fill_in 'Password', with: 'password'
      fill_in 'Password confirmation', with: 'password'
      click_button 'Create my account'
    }.to change { User.count }.by(1)

    expect(page).to have_selector('.alert-info')
    expect(page.body).to have_content('please  check your email to activate your account.')
    expect(ActionMailer::Base.deliveries.size).to eq 1
  end
end
