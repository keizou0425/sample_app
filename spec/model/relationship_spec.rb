require 'rails_helper'

RSpec.describe Relationship, type: :model do
  let(:user) { create(:user) }
  let(:alice) { create(:user, :alice) }
  let(:relationship) { Relationship.new(follower_id: user.id, followed_id: alice.id) }

  it '有効なRelationship' do
    expect(relationship.valid?).to be_truthy
  end

  it 'follower_idが必須' do
    relationship.follower_id = nil
    expect(relationship.valid?).to be_falsey
  end

  it 'followed_idが必須' do
    relationship.followed_id = nil
    expect(relationship.valid?).to be_falsey
  end
end
