require "rails_helper"

RSpec.describe "Users signup", type: :request do

  describe 'ユーザー登録' do
    it '正しい値であると非有効化状態でUserを登録できる' do
      ActionMailer::Base.deliveries.clear

      expect {
        post users_path, params: {
          user: {
            name: 'Rails',
            email: 'rails@example.com',
            password: 'foobar',
            password_confirmation: 'foobar'
          }
        }
      }.to change(User, :count).by(1)

      expect(ActionMailer::Base.deliveries.size).to eq 1
    end

    it '不正な値ではUserを登録できないこと' do
      expect {
        post users_path, params: {
          user: {
            name: '',
            email: 'user@invalid',
            password: 'foo',
            password_confirmation: 'bar'
          }
        }
      }.not_to change(User, :count)
      expect(is_logged_in?).to be_falsy
    end
  end

  describe 'アカウントの有効化' do
    let(:user) { controller.instance_variable_get("@user") }

    before do
      ActionMailer::Base.deliveries.clear

      post users_path, params: {
        user: {
          name: "Example User",
          email: "user@example.com",
          password: "password",
          password_confirmation: "password"
        }
      }
    end

    it '登録直後は非有効化状態であること' do
      expect(user.activated?).to be_falsey
    end

    it '非有効化状態ではログインできない' do
      log_in_as(user)
      expect(is_logged_in?).to be_falsey
    end

    it '有効化トークンが間違っていると有効化できずにログインに失敗する' do
      get edit_account_activation_path('invalid token', email: user.email)
      expect(is_logged_in?).to be_falsey
    end

    it 'emailが間違っていると有効化できずにログインに失敗する' do
      get edit_account_activation_path(user.activation_token, email: 'wrong')
      expect(is_logged_in?).to be_falsey
    end

    it '有効化トークンもemailも正しいとアカウントが有効化される' do
      get edit_account_activation_path(user.activation_token, email: user.email)
      expect(user.reload.activated?).to be_truthy
      expect(is_logged_in?).to be_truthy
    end
  end
end
