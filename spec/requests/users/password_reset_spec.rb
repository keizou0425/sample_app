require "rails_helper"

RSpec.describe "Password reset", type: :request do
  let(:user) { create(:user) }
  let(:reset_user) { controller.instance_variable_get("@user") }

  before do
    ActionMailer::Base.deliveries.clear

    post password_resets_path, params: {
      password_reset: {
        email: user.email
      }
    }
  end

  it 'パスワードのリセットができる' do
    expect(user.reset_digest).not_to eq reset_user.reset_digest
    expect(ActionMailer::Base.deliveries.size).to eq 1
    expect(flash.empty?).to be_falsey
    expect(response).to redirect_to root_url
  end

  it '不正なemailであればパスワードのリセットフォームにアクセスできない' do
    get edit_password_reset_path(reset_user.reset_token, email: "")
    expect(response).to redirect_to root_url
  end

  it '非有効化状態のユーザーはパスワードのリセットフォームにアクセスできない' do
    reset_user.toggle!(:activated)
    get edit_password_reset_path(reset_user.reset_token, email: reset_user.email)
    expect(response).to redirect_to root_url
  end

  it 'emailは正しいが、トークンが間違っている時、パスワードのリセットフォームにアクセスできない' do
    get edit_password_reset_path('wrong token', email: reset_user.email)
    expect(response).to redirect_to root_url
  end

  it 'passwordとpassword_confirmationが一致していないとリセットできない' do
    patch password_reset_path(reset_user.reset_token), params: {
      email: reset_user.email,
      user: {
        password: 'foobaz',
        password_confirmation: 'barquux'
      }
    }
    expect(response.body).to match "Password confirmation doesn&#39;t match Password"
  end

  it 'passwordが空だとリセットできない' do
    patch password_reset_path(reset_user.reset_token), params: {
      email: reset_user.email,
      user: {
        password: '',
        password_confirmation: ''
      }
    }
    expect(response.body).to match "Password cant be empty"
  end

  it 'passwordとpassword_confirmationが正しいとリセットできる' do
    patch password_reset_path(reset_user.reset_token), params: {
      email: reset_user.email,
      user: {
        password: 'barbaz',
        password_confirmation: 'barbaz'
      }
    }

    expect(is_logged_in?).to be_truthy
    expect(flash.empty?).to be_falsey
    expect(response).to redirect_to reset_user
  end

  it 'トークンの期限が切れていたらリセットできない' do
    reset_user.update_attribute(:reset_sent_at, 3.hours.ago)
    patch password_reset_path(reset_user.reset_token), params: {
      email: reset_user.email,
      user: {
        password: 'barbaz',
        password_confirmation: 'barbaz'
      }
    }

    expect(is_logged_in?).to be_falsey
    expect(response).to redirect_to new_password_reset_url
  end
end
