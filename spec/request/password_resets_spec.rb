require 'rails_helper'

RSpec.describe "Password resets", type: :request do
  let(:user) { create(:user) }

  before do
    ActionMailer::Base.deliveries.clear
    post password_resets_path, params: {
      password_reset: {
        email: user.email
      }
    }
    @reset_user = controller.instance_variable_get("@user")
  end

  it '正しいemailアドレスだとリセットするためのメールが届く' do
    expect(user.reset_digest).not_to eq @reset_user.reset_digest
    expect(ActionMailer::Base.deliveries.size).to eq 1
  end

  it 'URLパラメータに不正なemailが与えられていた場合パスワードリセットのフォームにアクセスできない' do
    get edit_password_reset_path(@reset_user.reset_token, email: '')
    expect(response).to redirect_to root_url
  end

  it '有効化されていないユーザーはパスワードリセットのフォームにアクセスできない' do
    @reset_user.toggle!(:activated)
    get edit_password_reset_path(@reset_user.reset_token, email: @reset_user.email)
    expect(response).to redirect_to root_url
  end

  it 'URLパラメータに不正なトークンが与えられていた場合パスワードリセットのフォームにアクセスできない' do
    get edit_password_reset_path('wrong token', email: @reset_user.email)
    expect(response).to redirect_to root_url
  end

  it 'URLパラメータに正しいトークンと正しいemailが与えられていた場合パスワードリセットのフォームにアクセスできる' do
    get edit_password_reset_path(@reset_user.reset_token, email: @reset_user.email)
    expect(response.body).to include('Confirmation')
    expect(response.body).to include('Password')
    expect(response.body).to include('Update password')
  end

  it '入力したパスワードと確認用パスワードが違うとパスワードをリセットできない' do
    patch password_reset_path(@reset_user.reset_token), params: {
      email: @reset_user.email,
      user: {
        password: 'foobaz',
        password_confirmation: 'barquux'
      }
    }
    expect(response.body).to include("Password confirmation doesn&#39;t match Password")
  end

  it 'パスワードが空の場合リセットできない' do
    patch password_reset_path(@reset_user.reset_token), params: {
      email: @reset_user.email,
      user: {
        password: '',
        password_confirmation: ''
      }
    }
    expect(response.body).to include("Password cant be empty")
  end

  it '正しくパスワードと確認用パスワードを入力するとリセットできる' do
    patch password_reset_path(@reset_user.reset_token), params: {
      email: @reset_user.email,
      user: {
        password: 'foobaz',
        password_confirmation: 'foobaz'
      }
    }
    expect(is_logged_in?).to be_truthy
    expect(response).to redirect_to user_path(@reset_user)
  end

  it '有効期限が切れたトークンではリセットできない' do
    @reset_user.update_attribute(:reset_sent_at, 3.hours.ago)

    patch password_reset_path(@reset_user.reset_token), params: {
      email: @reset_user.email,
      user: {
        password: 'foobaz',
        password_confirmation: 'foobaz'
      }
    }
    expect(response).to redirect_to new_password_reset_url
  end
end
