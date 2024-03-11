require "rails_helper"

RSpec.describe "Users login", type: :request do
  let(:user) { create(:user) }

  it "正しいログイン情報でログイン" do
    post login_path, params: {
      session: {
        email: user.email,
        password: "password"
      }
    }
    expect(response.status).to be 302
  end

  it 'emailが正しく、passwordが間違い' do
    post login_path, params: {
      session: {
        email: user.email,
        password: "passwordddddddddd"
      }
    }
    expect(response.status).to be 422
  end

  it 'passwordが正しく、emailが間違い' do
    post login_path, params: {
      session: {
        email: user.email + "foo",
        password: "password"
      }
    }
    expect(response.status).to be 422
  end

  it 'email,password共に空白' do
    post login_path, params: {
      session: {
        email: '',
        password: ''
      }
    }
    expect(response.status).to be 422
    expect(flash.empty?).to be_falsy
    get root_path
    expect(flash.empty?).to be_truthy
  end

  it 'ログアウト' do
    post login_path, params: {
      session: {
        email: user.email,
        password: "password"
      }
    }
    expect(is_logged_in?).to be_truthy

    delete logout_path

    expect(response.status).to be 303
    expect(is_logged_in?).to be_falsy
  end

  it 'ログアウト後も別のウィンドウでログアウトした時にエラーにならないこと' do
    log_in_as(user)

    expect(is_logged_in?).to be_truthy
    # ログアウト
    delete logout_path

    # ログアウト済み確認
    expect(is_logged_in?).to be_falsy
    # ログアウトを試みる
    delete logout_path
    # エラーが起きずにリダイレクト処理
    expect(response.status).to be 303
  end

  it 'ログイン状態を永続的に維持するログイン' do
    log_in_as(user, remember_me: '1')
    expect(cookies[:remember_token].blank?).to be_falsey
  end

  it 'ログイン状態を永続的に維持しないログイン' do
    log_in_as(user, remember_me: '1')
    log_in_as(user, remember_me: '0')
    expect(cookies[:remember_token].blank?).to be_truthy
  end
end
