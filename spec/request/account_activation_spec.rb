require 'rails_helper'

RSpec.describe "Account activation", type: :request do
  before do
    post users_path, params: {
      user: {
        name: 'Example User',
        email: 'user@example.com',
        password: 'password',
        password_confirmation: 'password'
      }
    }
    @user = controller.instance_variable_get("@user")
  end

  it '登録直後のユーザーは非有効状態であること' do
    expect(@user.activated?).to be_falsey
  end

  it '有効状態になる前はログインできない' do
    log_in_as(@user)
    expect(is_logged_in?).to be_falsey
  end

  it '無効な有効化トークンでは有効化できない' do
    get edit_account_activation_path('invalid token', email: @user.email)
    expect(is_logged_in?).to be_falsey
  end

  it '無効なemailアドレスでは有効化できない' do
    get edit_account_activation_path(@user.activation_token, email: 'wrong')
    expect(is_logged_in?).to be_falsey
  end

  it '正しい有効化トークンとemailアドレスの組み合わせであれば有効化できる' do
    get edit_account_activation_path(@user.activation_token, email: @user.email)
    expect(@user.reload.activated?).to be_truthy
    expect(is_logged_in?).to be_truthy
  end
end
