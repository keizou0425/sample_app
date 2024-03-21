require 'rails_helper'

RSpec.describe MicropostsHelper, type: :helper do
  describe '#content_for_reply' do
    it 'content内に@nameがあり、かつ、そのユーザーが存在するとその部分がリンクとなる' do
      user = FactoryBot.create(:user, name: 'hey')
      micropost = user.microposts.create!(content: '@hey hello!')
      expect(content_for_reply(micropost.content)).to eq "<a href=\"/users/#{user.id}\">@hey</a> hello!"
    end

    it 'content内に@nameがあるが、そのユーザーが存在しない場合、普通の文字列として表示する' do
      user = FactoryBot.create(:user, name: 'hey')
      micropost = user.microposts.create!(content: '@heyyyy hello!')
      expect(content_for_reply(micropost.content)).to eq "@heyyyy hello!"
    end

    it 'content内に@nameが複数あり、その内一つがユーザーが存在し、もう一つがユーザーが存在しない' do
      user = FactoryBot.create(:user, name: 'hey')
      micropost = user.microposts.create!(content: '@hey hello! and @hi hello!')
      expect(content_for_reply(micropost.content)).to eq "<a href=\"/users/#{user.id}\">@hey</a> hello! and @hi hello!"
    end
  end
end
