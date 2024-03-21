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

    it 'micropostのcontent文字列から@nameを抜き出す' do
      alice = FactoryBot.create(:user, :alice)
      post.content = "hello! @alice!"
      expect(post.send(:pick_out_reply)).to eq [alice.name]
    end

    it 'micropostのcontent文字列から複数の@nameを抜き出す' do
      alice = FactoryBot.create(:user, :alice)
      bob = FactoryBot.create(:user, :bob)
      post.content = "hello! @alice! and @bob."
      expect(post.send(:pick_out_reply)).to eq [alice.name, bob.name]
    end

    it '改行を含むmicropostのcontent文字列から@nameを抜き出す' do
      alice = FactoryBot.create(:user, :alice)
      post.content = "これは\n改行\nが\n含まれる\n文字列ですte\nst。@ali\nce "
      expect(post.send(:pick_out_reply)).to eq [alice.name]
    end

    it '@nameのユーザーが存在しない場合空の配列を返す' do
      post.content = "hello @alilililice , nice to meet you."
      expect(post.send(:pick_out_reply)).to eq []
    end

    it '@nameが連続して続く時もそれぞれ認識できる' do
      alice = FactoryBot.create(:user, :alice)
      bob = FactoryBot.create(:user, :bob)
      post.content = "hello! @alice@bob."
      expect(post.send(:pick_out_reply)).to eq [alice.name, bob.name]
    end

    it 'contentに@nameが含まれていなければ空の配列を返す' do
      post.content = "hello alice, nice to meet you."
      expect(post.send(:pick_out_reply)).to eq []
    end
  end

  describe '#add_in_reply_to' do
    let(:user) { create(:user) }
    let(:post) { user.microposts.build }

    it 'micropostのcontent文字列から@nameのnameを取り出し、in_reply_toに保存する' do
      alice = FactoryBot.create(:user, :alice)
      post.content = "hello! @alice!"
      post.save!
      expect(post.in_reply_to).to eq "alice"
    end

    it 'micropostのcontent文字列から複数の@nameのnameを取り出し、in_reply_toに保存する' do
      alice = FactoryBot.create(:user, :alice)
      bob = FactoryBot.create(:user, :bob)
      post.content = "hello! @alice! and @bob."
      post.save!
      expect(post.in_reply_to).to eq "alice,bob"
    end

    it '存在しないユーザーはin_reply_toに保存しない' do
      alice = FactoryBot.create(:user, :alice)
      bob = FactoryBot.create(:user, :bob)
      post.content = "hello! @alice! and @bob. @unknown"
      post.save!
      expect(post.in_reply_to).to eq "alice,bob"
    end

    it 'contentに@nameがない場合何も保存しない' do
      alice = FactoryBot.create(:user, :alice)
      bob = FactoryBot.create(:user, :bob)
      post.content = "hello! alice! and bob. unknown"
      post.save!
      expect(post.in_reply_to).to eq nil
    end
  end
end
