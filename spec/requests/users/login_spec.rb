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
end
