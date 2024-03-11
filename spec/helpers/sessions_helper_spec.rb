require 'rails_helper'

RSpec.describe SessionsHelper, type: :helper do
  let(:user) { create(:user) }

  before do
    # この時点でsession[:user_id]はnil = ログインできていない
    remember(user)
  end

  it "sessionがnilの場合はcurrent_userは正しいuserを返す" do
    # session[:user_id]は無いがrememberしているのでcookiesにはトークンが入っていて、それを検証することでuserを返せる(ログイン)。
    expect(user).to eq current_user
    # current_userを呼び出した後はログイン済みになっているはずなのでここはtrue
    expect(is_logged_in?).to be_truthy
  end

  it 'remember_digestの値が不正ならcurrent_userはnilを返す' do
    user.update_attribute(:remember_digest, User.digest(User.new_token))
    expect(current_user).to be_nil
  end
end
