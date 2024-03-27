xml.instruct! :xml, version: '1.0'
xml.rss(version: '2.0') do
  xml.channel do
    xml.title "#{@user.name}の投稿一覧"
    xml.description "#{@user.name}の最新の投稿"
    xml.link "https://https://sample-app-04xx.onrender.com/#{@user.id}"
    xml.lastBuildDate @microposts.last.created_at.rfc2822
    xml.language 'ja'
    @microposts.each do |micropost|
      xml.item do
        xml.title micropost.content
        xml.pubDate micropost.created_at.rfc2822
        xml.link "https://https://sample-app-04xx.onrender.com/#{@user.id}"
      end
    end
  end
end
