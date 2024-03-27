xml.instruct! :xml, version: '1.0'
xml.rss(version: '2.0') do
  xml.channel do
    xml.title "#{@title}"
    xml.description "#{@description}"
    xml.link "https://sample-app-04xx.onrender.com/users/#{@user.id}"
    unless @microposts.last.nil?
      xml.lastBuildDate @microposts.last.created_at.rfc2822
      xml.language 'ja'
      @microposts.each do |micropost|
        xml.item do
          xml.title micropost.content
          xml.pubDate micropost.created_at.rfc2822
          xml.link "https://sample-app-04xx.onrender.com/users/#{@user.id}"
        end
      end
    end
  end
end
