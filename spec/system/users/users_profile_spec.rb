require 'rails_helper'

RSpec.describe "Users profile", type: :system do
  include ApplicationHelper

  before do
    driven_by(:rack_test)
  end

  let(:with_post) { create(:user, :with_post) }

  scenario 'プロフィール画面' do
    visit login_path
    fill_in 'Email', with: with_post.email
    fill_in 'Password', with: "password"
    click_button 'Log in'

    expect(current_path).to eq user_path(with_post)
    expect(page).to have_title(full_title(with_post.name))
    expect(page).to have_selector('h1', text: with_post.name)
    expect(page).to have_content(with_post.microposts.count.to_s)
    expect(page).to have_selector('div.pagination')
    with_post.microposts.paginate(page: 1).each do |micropost|
      expect(page).to have_content(micropost.content)
    end
  end
end
