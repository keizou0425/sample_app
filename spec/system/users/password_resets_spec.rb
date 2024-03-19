require 'rails_helper'

RSpec.describe "Password resets", type: :system do
  before do
    driven_by(:rack_test)
  end

  let(:user) { create(:user) }

  scenario 'パスワードリセットのフォームが正しく表示される' do
    visit new_password_reset_path
    expect(page).to have_field('Email', type: 'email')
  end

  scenario '不正なemailを送信すると元のフォーム画面に差し戻される' do
    visit new_password_reset_path
    fill_in 'Email', with: ''
    click_button 'Submit'

    expect(page).to have_content 'Email address not found'
    expect(page).to have_selector '.alert-danger'
  end
end
