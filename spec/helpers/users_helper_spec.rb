require 'rails_helper'

RSpec.describe UsersHelper, type: :helper do
  describe '#avatar_for' do
    it 'ユーザーのプロフィール画像が表示される' do
      user = FactoryBot.create(:user)

    end
  end
end
