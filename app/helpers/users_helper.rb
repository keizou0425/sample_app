module UsersHelper
  def avatar_for(user, options = { size: [80, 80]})
    size = options[:size]
    image_tag user.avatar.variant(resize_to_limit: size)
  end
end
