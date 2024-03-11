require 'rails_helper'

RSpec.describe 'User edit', type: :request do
  let(:user) { create(:user) }

  it '編集が成功するとフラッシュメッセージが表示され、編集した項目が更新される' do
    log_in_as(user)
    get edit_user_path(user)
    name = 'Bar Foo'
    email = 'foo@bar.com'
    patch user_path(user), params: {
      user: {
        name: name,
        email: email,
        password: '',
        password_confirmation: ''
      }
    }

    expect(flash.empty?).to be_falsey
    user.reload
    expect(user.name).to eq name
    expect(user.email).to eq email
  end
end
