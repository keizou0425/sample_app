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

    it 'content内に@nameが二つあり、その内一つがユーザーが存在し、もう一つがユーザーが存在しない' do
      user = FactoryBot.create(:user, name: 'hey')
      micropost = user.microposts.create!(content: '@hey hello! and @hi hello!')
      expect(content_for_reply(micropost.content)).to eq "<a href=\"/users/#{user.id}\">@hey</a> hello! and @hi hello!"
    end

    it 'content内に@nameが三つあり、その内二つがユーザーが存在し、一つがユーザーが存在しない' do
      user_hey = FactoryBot.create(:user, name: 'hey')
      user_hi = FactoryBot.create(:user, name: 'hi')
      micropost = user_hey.microposts.create!(content: '@hey hello! and @hi hello! and @yey!')
      expect(content_for_reply(micropost.content)).to eq "<a href=\"/users/#{user_hey.id}\">@hey</a> hello! and <a href=\"/users/#{user_hi.id}\">@hi</a> hello! and @yey!"
    end

    it 'content内の@nameの後ろに.が続く時' do
      user = FactoryBot.create(:user, name: 'hey')
      micropost = user.microposts.create!(content: '@hey. hello! and @hi hello!')
      expect(content_for_reply(micropost.content)).to eq "<a href=\"/users/#{user.id}\">@hey</a>. hello! and @hi hello!"
    end

    it 'content内の@nameの後ろに!が続く時' do
      user = FactoryBot.create(:user, name: 'hey')
      micropost = user.microposts.create!(content: '@hey! hello! and @hi hello!')
      expect(content_for_reply(micropost.content)).to eq "<a href=\"/users/#{user.id}\">@hey</a>! hello! and @hi hello!"
    end
  end
end
