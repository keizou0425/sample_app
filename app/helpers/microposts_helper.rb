module MicropostsHelper
  def content_for_reply(content)
    str = content.gsub(/@(\w+)/) do |match|
      user = User.find_by(name: $1)
      user ? link_to(match, user) : match
    end
    sanitize(str, tags: ['a'], attributes: ['href'])
  end
end
