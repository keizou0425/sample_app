require 'rails_helper'

RSpec.describe "Micropost interface", type: :system do
  before do
    driven_by(:rack_test)
  end

  let(:with_post) { create(:user, :with_post) }
  let(:alice) { create(:user, :alice) }

  scenario 'ポストのページネーション' do
    visit login_path
    fill_in 'Email', with: with_post.email
    fill_in 'Password', with: "password"
    click_button 'Log in'

    visit root_path
    expect(page).to have_selector('div.pagination')
  end

  scenario '不正な内容のポストは作成できない' do
    visit login_path
    fill_in 'Email', with: with_post.email
    fill_in 'Password', with: "password"
    click_button 'Log in'

    visit root_path
    expect(page).to have_selector('div.pagination')

    expect {
      fill_in 'micropost_content', with: ''
      click_button 'Post'
    }.not_to change { Micropost.count }
    expect(page).to have_selector('div#error_explanation')
    expect(page).to have_link(nil, href: '/?page=2')
  end

  scenario '正しい内容のポストは作成できる' do
    visit login_path
    fill_in 'Email', with: with_post.email
    fill_in 'Password', with: "password"
    click_button 'Log in'

    visit root_path
    expect(page).to have_selector('div.pagination')

    submission_content = 'foobar'

    expect {
      fill_in 'micropost_content', with: submission_content
      click_button 'Post'
    }.to change { Micropost.count }.by(1)

    display_content = find('span.content', text: submission_content)

    expect(display_content).to be_truthy
  end

  scenario '自分のポストには削除用リンクが表示されている' do
    visit login_path
    fill_in 'Email', with: with_post.email
    fill_in 'Password', with: "password"
    click_button 'Log in'

    expect(page).to have_selector('a', text: 'delete')
  end

  scenario '自身のポストを削除できる' do
    visit login_path
    fill_in 'Email', with: with_post.email
    fill_in 'Password', with: "password"
    click_button 'Log in'

    delete_link = first('a', text: 'delete')
    expect {
      delete_link.click
    }.to change { Micropost.count }.by(-1)
  end

  scenario '他者のポストには削除用リンクが表示されていない' do
    alice.microposts.create!(content: 'test')

    visit login_path
    fill_in 'Email', with: with_post.email
    fill_in 'Password', with: "password"
    click_button 'Log in'

    visit user_path(alice)
    expect(page).not_to have_selector('a', text: 'delete')
  end

  scenario 'サイドバーに正しいポスト数が表示されている(複数のポスト)' do
    visit login_path
    fill_in 'Email', with: with_post.email
    fill_in 'Password', with: "password"
    click_button 'Log in'
    visit root_path

    expect(page).to have_content("#{with_post.microposts.count} microposts")
  end

  scenario 'サイドバーに正しいポスト数が表示されている(ポストが0件)' do
    visit login_path
    fill_in 'Email', with: alice.email
    fill_in 'Password', with: "password"
    click_button 'Log in'
    visit root_path

    expect(page).to have_content("0 microposts")
  end

  scenario 'サイドバーに正しいポスト数が表示されている(ポストが1件)' do
    alice.microposts.create!(content: 'test')

    visit login_path
    fill_in 'Email', with: alice.email
    fill_in 'Password', with: "password"
    click_button 'Log in'
    visit root_path

    expect(page).to have_content("1 micropost")
  end

  scenario '画像アップロード用のフィールドがあること' do
    visit login_path
    fill_in 'Email', with: with_post.email
    fill_in 'Password', with: "password"
    click_button 'Log in'

    visit root_path
    expect(page).to have_field(nil, type: 'file')
  end

  scenario '画像をポストに添付することができる' do
    visit login_path
    fill_in 'Email', with: with_post.email
    fill_in 'Password', with: "password"
    click_button 'Log in'

    visit root_path
    expect(page).not_to have_selector(".attached-image")

    find('#micropost_image').attach_file("#{Rails.root}/spec/fixtures/files/kitten.jpg")
    fill_in 'micropost_content', with: 'foobar'
    click_button 'Post'

    expect(page).to have_selector(".attached-image")
  end
end
