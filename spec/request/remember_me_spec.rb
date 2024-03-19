require 'rails_helper'

RSpec.describe "Remember me", type: :request do
  let(:user) { create(:user) }

  it 'ログインの永続化' do
    log_in_as(user, remember_me: '1')
    expect(cookies[:remember_token]).not_to be_blank
  end

  it '一時セッションとしてログイン' do
    log_in_as(user, remember_me: '0')
    expect(cookies[:remember_me]).to be_blank
  end
end
