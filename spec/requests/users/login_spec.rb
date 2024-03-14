require "rails_helper"

RSpec.describe "Users login", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:admin_user) { create(:user, :admin_user) }

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

  it '未ログイン時にユーザー一覧ページにアクセスするとログインページにリダイレクトされる' do
    get users_path
    expect(response).to redirect_to login_path
  end

  it '未ログイン時にユーザー編集ページにアクセスするとログインページにリダイレクトされる' do
    get edit_user_path(user)
    expect(flash.empty?).to be_falsey
    expect(response).to redirect_to(login_path)
  end

  it '未ログイン時にユーザーを更新しようとするとログインページにリダイレクトされる' do
    patch user_path(user), params: {
      user: {
        name: user.name,
        email: user.email
      }
    }
    expect(flash.empty?).to be_falsey
    expect(response).to redirect_to(login_path)
  end

  it '自分以外のユーザーの編集ページにアクセスするとルートへリダイレクトされる' do
    log_in_as(other_user)
    get edit_user_path(user)
    expect(flash.empty?).to be_truthy
    expect(response).to redirect_to(root_path)
  end

  it '自分以外のユーザーを更新しようとするとルートへリダイレクトされる' do
    log_in_as(other_user)
    patch user_path(user), params: {
      user: {
        name: user.name,
        email: user.email
      }
    }
    expect(flash.empty?).to be_truthy
    expect(response).to redirect_to(root_path)
  end

  it 'フレンドリーフォワーディング' do
    get edit_user_path(user)
    log_in_as(user)
    expect(response).to redirect_to(edit_user_path(user))
  end

  it 'フレンドリーフォワーディングは初回の1回のみであること' do
    get edit_user_path(user)
    expect(session[:forwarding_url]).to eq edit_user_url(user)
    log_in_as(user)
    expect(session[:forwarding_url]).to be_nil
  end

  it 'admin属性はweb経由で更新されない' do
    log_in_as(user)
    expect(user.admin?).to be_falsey
    patch user_path(user), params: {
      user: {
        password: "password",
        password_confirmation: "password",
        admin: true
      }
    }
    expect(user.reload.admin?).to be_falsey
  end

  it '非管理者はユーザーを削除できない' do
   log_in_as(user)
   other = other_user

   expect{
    delete user_path(other)
  }.not_to change(User, :count)
  end

  it '管理者はユーザーを削除できる' do
   log_in_as(admin_user)
   other = other_user

   expect{
    delete user_path(other)
  }.to change(User, :count).by(-1)
  end

  it '未ログイン状態でfollowingsページにアクセスするとログインページにリダイレクトされる' do
    get following_user_path(user)
    expect(response).to redirect_to login_url
  end

  it '未ログイン状態でfollowerページにアクセスするとログインページにリダイレクトされる' do
    get followers_user_path(user)
    expect(response).to redirect_to login_url
  end
end
