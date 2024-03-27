require 'rails_helper'

RSpec.describe "RSS feed", type: :request do
  let(:alice) { create(:user, :alice) }
  let(:bob) { create(:user, :bob) }

  it 'ユーザーごとにRSSを取得できる' do
    log_in_as(alice)
    3.times { |i| alice.microposts.create(content: "content-#{i + 1}")}

    get "/feeds/#{alice.id}.rss"

    expect(response).to have_http_status(200)
    expect(response.body).to include("xml version=\"1.0\"")
    expect(response.body).to include("<rss version=\"2.0\">")
    expect(response.body).to include("<title>#{alice.name}の投稿</title>")
    expect(response.body).to include("<description>#{alice.name}の最新の投稿</description>")
    expect(response.body).to include("<link>https://sample-app-04xx.onrender.com/users/#{alice.id}</link>")

    last_micropost = alice.microposts.last
    expect(response.body).to include("<lastBuildDate>#{last_micropost.created_at.rfc2822}</lastBuildDate>")
    expect(response.body).to include("<language>ja</language>")
    expect(response.body).to include("<title>#{last_micropost.content}</title>")
    expect(response.body).to include("<pubDate>#{last_micropost.created_at.rfc2822}</pubDate>")
    expect(response.body).to include("<link>https://sample-app-04xx.onrender.com/users/#{alice.id}</link>")
  end

  it 'ユーザーのフィードのRSSも取得できる' do
    log_in_as(alice)
    3.times { |i| alice.microposts.create(content: "content-#{i + 1}")}
    sleep(2)
    2.times { |i| bob.microposts.create(content: "content-#{i + 1}")}

    alice.follow(bob)

    get "/feeds/#{alice.id}.rss?feed=true"

    expect(response).to have_http_status(200)
    expect(response.body).to include("xml version=\"1.0\"")
    expect(response.body).to include("<rss version=\"2.0\">")
    expect(response.body).to include("<title>#{alice.name}のフィード</title>")
    expect(response.body).to include("<description>#{alice.name}の最新のフィード</description>")
    expect(response.body).to include("<link>https://sample-app-04xx.onrender.com/users/#{alice.id}</link>")

    last_micropost = alice.feed.last
    expect(response.body).to include("<lastBuildDate>#{last_micropost.created_at.rfc2822}</lastBuildDate>")
    expect(response.body).to include("<language>ja</language>")
    expect(response.body).to include("<title>#{last_micropost.content}</title>")
    expect(response.body).to include("<pubDate>#{last_micropost.created_at.rfc2822}</pubDate>")
    expect(response.body).to include("<link>https://sample-app-04xx.onrender.com/users/#{alice.id}</link>")
  end
end
