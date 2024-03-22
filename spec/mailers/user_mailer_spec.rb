require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  let(:user) { create(:user) }

  it 'アカウント有効化' do
    user.activation_token = User.new_token
    mail = UserMailer.account_activation(user)

    expect(mail.subject).to eq 'Account activation'
    expect(mail.to[0]).to eq user.email
    expect(mail.from[0]).to eq 'from@example.com'
    expect(mail.body.encoded).to match user.name
    expect(mail.body.encoded).to match user.activation_token
    expect(mail.body.encoded).to match CGI.escape(user.email)
  end

  it 'パスワードリセット' do
    user.reset_token = User.new_token
    mail = UserMailer.password_reset(user)

    expect(mail.subject).to eq 'Password reset'
    expect(mail.to[0]).to eq user.email
    expect(mail.from[0]).to eq 'from@example.com'
    expect(mail.body.encoded).to match user.reset_token
    expect(mail.body.encoded).to match CGI.escape(user.email)
  end

  it 'フォロー通知' do
    alice = FactoryBot.create(:user, :alice)
    bob = FactoryBot.create(:user, :bob)

    alice.follow(bob)
    mail = UserMailer.be_followed(alice, bob)

    expect(mail.subject).to eq 'You are followed'
    expect(mail.to[0]).to eq bob.email
    expect(mail.from[0]).to eq 'from@example.com'
    expect(mail.body.encoded).to match "You are followed by #{alice.name}"
  end
end
