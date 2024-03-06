require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { User.new(name: "example",
                        email: "user@examle.com",
                        password: "foobar",
                        password_confirmation: "foobar") }

  it "正しいユーザー" do
    expect(user.valid?).to be_truthy
  end

  it "名前は必須であること" do
    user.name = "   "
    expect(user.valid?).to be_falsey
  end

  it "メールアドレスは必須であること" do
    user.email = "   "
    expect(user.valid?).to be_falsey
  end

  it "名前は長すぎてはダメ" do
    user.name = "a" * 51
    expect(user.valid?).to be_falsey
  end

  it "メールアドレスは長すぎてはダメ" do
    user.email = "a" * 244 + "@example.com"
    expect(user.valid?).to be_falsey
  end

  it "メールアドレスは正しいフォーマットでなければならないこと" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example. foo@bar_baz.com foo@bar+baz.com]

    invalid_addresses.each do |invalid_address|
      user.email = invalid_address
      expect(user.valid?).to be_falsey
    end
  end

  it "メールアドレスは一意であること" do
    duplicate_user = user.dup
    user.save
    expect(duplicate_user.valid?).to be_falsey
  end

  it "メールアドレスは小文字に変換され保存されること" do
    mixed_case_email = "Foo@ExAMPle.CoM"
    user.email = mixed_case_email
    user.save
    expect(mixed_case_email.downcase).to eq user.reload.email
  end

  it "パスワードは空白ではダメなこと" do
    user.password = user.password_confirmation = " " * 6
    expect(user.valid?).to be_falsey
  end

  it "パスワードは最低でも6文字であること" do
    user.password = user.password_confirmation = "a" * 5
    expect(user.valid?).to be_falsey
  end
end
