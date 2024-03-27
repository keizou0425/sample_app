User.create!(
  name: "AdminUser",
  email: "admin@example.com",
  password: "foobar",
  password_confirmation: "foobar",
  admin: true,
  activated: true,
  activated_at: Time.zone.now
)

4.times do |n|
  name = "sample-#{n}"
  email = "sample-#{n + 1}@example.com"
  password = "foobar"
  User.create!(
    name: name,
    email: email,
    password: password,
    password_confirmation: password,
    activated: true,
    activated_at: Time.zone.now
  )
end

users = User.all
users.map(&:default_image_attache)
