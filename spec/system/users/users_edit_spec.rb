require 'rails_helper'

RSpec.describe "Users edit", type: :system do
  before do
    driven_by(:rack_test)
  end

  let(:alice) { create(:user, :alice) }

  scenario '更新データに不備があると更新に失敗すること' do
    visit login_path
    fill_in 'Email', with: alice.email
    fill_in 'Password', with: "password"
    click_button 'Log in'
    visit edit_user_path(alice)

    fill_in 'Name', with: ""
    fill_in 'Email', with:"invalid@invalid"
    fill_in 'Password', with: 'foo'
    fill_in 'Password confirmation', with: 'bar'
    click_button 'Save changes'

    expect(page).to have_content 'The form contains 4 errors.'
  end

  scenario '更新データに不備がなければ更新できる' do
    visit login_path
    fill_in 'Email', with: alice.email
    fill_in 'Password', with: "password"
    click_button 'Log in'
    visit edit_user_path(alice)

    fill_in 'Name', with: "bob"
    fill_in 'Email', with:"valid@example.com"
    fill_in 'Password', with: 'foobar'
    fill_in 'Password confirmation', with: 'foobar'
    uncheck 'user_notice'
    click_button 'Save changes'

    expect(page).to have_selector('.alert-success')
    expect(page.body).to have_content('updated!')
    expect(alice.reload.name).to eq 'bob'
    expect(alice.reload.email).to eq 'valid@example.com'
    expect(alice.notice?).to be_falsey
  end

  scenario 'フレンドリーフォワーディング' do
    visit edit_user_path(alice)
    expect(current_path).to eq login_path

    fill_in 'Email', with: alice.email
    fill_in 'Password', with: "password"
    click_button 'Log in'
    expect(current_path).to eq edit_user_path(alice)
  end
end

