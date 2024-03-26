require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { User.new(name: "example",
                        email: "user@examle.com",
                        password: "foobar",
                        password_confirmation: "foobar") }

  let(:alice) { FactoryBot.create(:user, :alice) }
  let(:bob) { FactoryBot.create(:user, :bob) }
  let(:carol) { FactoryBot.create(:user, :carol) }
  let(:dave) { FactoryBot.create(:user, :dave) }

  it "正しいユーザー" do
    expect(user).to be_valid
  end

  it "名前は必須であること" do
    user.name = "   "
    expect(user).to be_invalid
  end

  it '名前にスペースを含んではいけない' do
    user.name = 'rails rails'
    expect(user).to be_invalid
  end

  it '名前は一意であること' do
    duplicate_user = user.dup
    duplicate_user.email = 'foo@example.com'
    user.save
    expect(duplicate_user).to be_invalid
  end

  it "メールアドレスは必須であること" do
    user.email = "   "
    expect(user).to be_invalid
  end

  it "名前は長すぎてはダメ" do
    user.name = "a" * 51
    expect(user).to be_invalid
  end

  it "メールアドレスは長すぎてはダメ" do
    user.email = "a" * 244 + "@example.com"
    expect(user).to be_invalid
  end

  it "メールアドレスは正しいフォーマットでなければならないこと" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example. foo@bar_baz.com foo@bar+baz.com]

    invalid_addresses.each do |invalid_address|
      user.email = invalid_address
      expect(user).to be_invalid
    end
  end

  it "メールアドレスは一意であること" do
    duplicate_user = user.dup
    user.save
    expect(duplicate_user).to be_invalid
  end

  it "メールアドレスは小文字に変換され保存されること" do
    mixed_case_email = "Foo@ExAMPle.CoM"
    user.email = mixed_case_email
    user.save
    expect(mixed_case_email.downcase).to eq user.reload.email
  end

  it "パスワードは空白ではダメなこと" do
    user.password = user.password_confirmation = " " * 6
    expect(user).to be_invalid
  end

  it "パスワードは最低でも6文字であること" do
    user.password = user.password_confirmation = "a" * 5
    expect(user).to be_invalid
  end

  it "userのdigestがnilの場合、authenticated?メソッドはfalseを返すこと" do
    expect(user.authenticated?(:remember, user.remember_token)).to be_falsey
  end

  it "ユーザーが削除されると一緒に投稿も削除される" do
    user.save
    user.microposts.create!(content: "lorem ipsum")
    expect {
      user.destroy
  }.to change { Micropost.count }.by(-1)
  end

  it 'ユーザーは登録直後は通知設定がtrueである' do
    user.save
    expect(user.notice?).to be_truthy
  end

  it 'フォローとアンフォロー' do
    user.save
    expect(user.following?(alice)).to be_falsey
    user.follow(alice)
    expect(alice.followers).to include(user)
    expect(user.following?(alice)).to be_truthy
    user.unfollow(alice)
    expect(user.following?(alice)).to be_falsey
    user.follow(user)
    expect(user.following?(user)).to be_falsey
  end

  it 'フォローするとフォローされた人にメールで通知される' do
    ActionMailer::Base.deliveries.clear
    user.save

    expect(ActionMailer::Base.deliveries.size).to eq 0
    user.follow(alice)
    expect(ActionMailer::Base.deliveries.size).to eq 1
  end

  it 'feedには自身と、自身がフォローしたユーザーの投稿しか含まれていない' do
    user.save
    user.follow(alice)

    alice.microposts.each do |micropost|
      expect(user.feed).to include(micropost)
    end

    user.microposts.each do |micropost|
      expect(user.feed).not_to include(micropost)
    end

    bob.microposts.each do |micropost|
      expect(user.feed).not_to include(micropost)
    end
  end

  it 'ユーザーは他のユーザーとDMを作成する事ができる' do
    conversation = alice.create_conversation_with(bob)

    expect(conversation).to eq bob.conversations[0]
  end

  it 'ユーザーは他のユーザーとのDMを取得できる' do
    conversation_with_bob = alice.create_conversation_with(bob)
    conversation_with_carol = alice.create_conversation_with(carol)

    expect(alice.get_conversation_with(bob)).to eq conversation_with_bob
    expect(alice.get_conversation_with(carol)).to eq conversation_with_carol
    expect(alice.get_conversation_with(dave)).to be_nil
  end

  it 'ユーザーはDMの相手をDMから取得できる' do
    conversation_with_bob = alice.create_conversation_with(bob)
    conversation_with_carol = alice.create_conversation_with(carol)

    expect(alice.get_target_user(conversation_with_bob)).to eq bob
    expect(alice.get_target_user(conversation_with_carol)).to eq carol
  end
end
