require 'rails_helper'

RSpec.describe "follow", type: :request do
  let(:user) { create(:user) }
  let(:alice) { create(:user, :alice) }

  it 'フォローできる' do
    log_in_as(user)

    expect {
      post relationships_path(params: {
        followed_id: alice.id
      })
    }.to change { Relationship.count }.by(1)
  end

  it 'アンフォローできる' do
    log_in_as(user)
    relationship = user.active_relationships.create(followed_id: alice.id)

    expect {
      delete relationship_path(relationship)
    }.to change { Relationship.count }.by(-1)
  end

  it 'Hotwireでフォローできる' do
    log_in_as(user)

    expect {
      post relationships_path(format: :turbo_stream, params: {
        followed_id: alice.id
      })
    }.to change { Relationship.count }.by(1)
  end

  it 'Hotwireでアンフォローできる' do
    log_in_as(user)
    relationship = user.active_relationships.create(followed_id: alice.id)

    expect {
      delete relationship_path(relationship, format: :turbo_stream)
    }.to change { Relationship.count }.by(-1)
  end

  it 'フォローするにはログインが必須' do
    expect {
      post relationships_path
  }.not_to change { Relationship.count }
  expect(response).to redirect_to login_url
  end

  it 'アンフォローするにはログインが必須' do
    relationship = FactoryBot.create(:relationship)
    expect {
      delete relationship_path(relationship)
  }.not_to change { Relationship.count }
  expect(response).to redirect_to login_url
  end
end
