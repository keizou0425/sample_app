require 'rails_helper'

RSpec.describe "Users show", type: :system do
  before do
    driven_by(:rack_test)
  end

  let(:alice) { create(:user, :alice) }
  let(:bob) { create(:user, :bob) }
  let(:in_activated) { create(:user, :in_activated) }

  scenario '有効化前のユーザーはルートにリダイレクトされる' do
    visit login_path
    fill_in 'Email', with: alice.email
    fill_in 'Password', with: "password"
    click_button 'Log in'

    visit user_path(in_activated)
    expect(current_path).to eq root_path
  end

  scenario '有効化済みのユーザーは正しく表示される' do
    visit login_path
    fill_in 'Email', with: alice.email
    fill_in 'Password', with: "password"
    click_button 'Log in'

    visit user_path(bob)
    expect(current_path).to eq user_path(bob)
  end

end
