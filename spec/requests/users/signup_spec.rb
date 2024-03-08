require "rails_helper"

RSpec.describe "Users signup", type: :request do

  it '正しい値であるとUserを登録できる' do
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
    follow_redirect!
    expect(is_logged_in?).to be_truthy
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
