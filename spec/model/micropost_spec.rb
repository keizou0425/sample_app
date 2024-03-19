require 'rails_helper'

RSpec.describe Micropost, type: :model do
  let(:micropost) { create(:micropost) }

  it 'マイクロポストには必ず投稿者が必要' do
    micropost.user_id = nil
    expect(micropost.valid?).to be_falsey
  end

  it 'マイクロポストは必ず本文が必要' do
    micropost.content = '  '
    expect(micropost.valid?).to be_falsey
  end

  it 'マイクロポストの本文は140文字以内' do
    micropost.content = 'a' * 141
    expect(micropost.valid?).to be_falsey
  end

  it 'デフォルトで投稿日時の新しい順に並ぶ' do
    FactoryBot.create(:micropost, :before_yestudy_post)
    FactoryBot.create(:micropost, :yestudy_post)
    most_recent_post = FactoryBot.create(:micropost, :most_recent_post)
    expect(most_recent_post).to eq Micropost.first
  end

  describe '#pick_out_reply' do
    let(:post) { build(:micropost) }

    it '改行を含む文字列から@replyを抜き出す' do
      post.content = "これは\n改行\nが\n含まれる\n文字列ですte\nst。@ali\nce "
      expect(post.pick_out_reply).to eq '@alice'
    end

    it '@replyの後ろに半角スペースがある場合' do
      post.content = "hello @alice , nice to meet you."
      expect(post.pick_out_reply).to eq '@alice'
    end

    it '@replyの後ろに半角スペースがない場合' do
      post.content = "hello @alice, nice to meet you."
      expect(post.pick_out_reply).to eq '@alice'
    end

    it 'contentに@replyが含まれていなければnilを返す' do
      post.content = "hello alice, nice to meet you."
      expect(post.pick_out_reply).to be_nil
    end
  end
end
