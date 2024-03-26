require 'rails_helper'

RSpec.describe "Users directmessage", type: :system do
  before do
    driven_by(:rack_test)
  end

  let(:alice) { create(:user, :alice) }
  let(:bob) { create(:user, :bob) }
  let(:carol) { create(:user, :carol) }

  scenario 'ユーザーはユーザー詳細画面から他のユーザーにDMを送信できる' do
    alice = FactoryBot.create(:user, :alice)
    bob = FactoryBot.create(:user, :bob)

    visit login_path
    fill_in 'Email', with: alice.email
    fill_in 'Password', with: "password"
    click_button 'Log in'

    expect {
      click_link 'Users'
      click_link 'bob'
      fill_in 'direct_message', with: 'hoge'
      click_button 'Send Message'
    }.to change { Message.count }.by(1)
     .and change { Conversation.count }.by(1)
     .and change { alice.conversations.count }.by(1)
     .and change { bob.conversations.count }.by(1)

    expect(page).to have_content("Your message has been sent")
    expect(current_path).to eq user_path(bob)

    click_link 'DM'
    expect(page).to have_content("Conversation with bob")
    click_link 'show this conversation'
    expect(page).to have_content("hoge")
  end

  scenario 'DM詳細画面からメッセージの送信ができる' do
    alice = FactoryBot.create(:user, :alice)
    bob = FactoryBot.create(:user, :bob)

    conversation = alice.create_conversation_with(bob)
    alice.messages.create!(
      content: 'hello',
      conversation: conversation
    )

    visit login_path
    fill_in 'Email', with: alice.email
    fill_in 'Password', with: "password"
    click_button 'Log in'

    click_link 'DM'
    click_link 'show this conversation'

    expect {
      fill_in 'direct_message', with: 'huga'
      click_button 'Send Message'
    }.to change { Message.count }.by(1)
     .and change { alice.messages.count }.by(1)

    expect(page).to have_content("Your message has been sent")
    expect(page).to have_content("huga")
    expect(current_path).to eq conversation_path(conversation)
  end

  scenario '未ログインのユーザーはDMにアクセスできない' do
    alice = FactoryBot.create(:user, :alice)
    bob = FactoryBot.create(:user, :bob)

    conversation = alice.create_conversation_with(bob)
    alice.messages.create!(
      content: 'hello',
      conversation: conversation
    )

    visit conversations_path

    expect(page).to have_content("please log in")
  end

  scenario 'DMの当事者しか詳細画面にアクセスできない' do
    alice = FactoryBot.create(:user, :alice)
    bob = FactoryBot.create(:user, :bob)
    carol = FactoryBot.create(:user, :carol)

    conversation = alice.create_conversation_with(bob)
    alice.messages.create!(
      content: 'hello',
      conversation: conversation
    )

    visit login_path
    fill_in 'Email', with: carol.email
    fill_in 'Password', with: "password"
    click_button 'Log in'

    visit conversation_path(conversation)
    expect(current_path).to eq root_path
  end
end

