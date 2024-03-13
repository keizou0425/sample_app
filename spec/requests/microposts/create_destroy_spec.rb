require "rails_helper"

RSpec.describe "Creating and Destroy", type: :request do
  let(:micropost) { create(:micropost) }

  it 'ログインしていない場合は投稿を作成できない' do
    expect {
      post microposts_path, params: {
        micropost: {
          content: 'lorem ipsum'
        }
      }
    }.not_to change { Micropost.count }
    expect(response).to redirect_to login_url
  end

  it 'ログインしていない場合は投稿を削除できない' do
    my_post = micropost

    expect {
      delete micropost_path(my_post)
    }.not_to change { Micropost.count }
    expect(response).to redirect_to login_url
  end

  it '自分がした投稿以外は削除できない' do
    me = FactoryBot.create(:user)
    alice = FactoryBot.create(:user, :alice)

    log_in_as(me)
    alice_post = alice.microposts.create!(content: 'hello')

    expect {
      delete micropost_path(alice_post)
    }.not_to change { Micropost.count }
    expect(response).to redirect_to root_url
  end
end
