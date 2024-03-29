class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token, :reset_token

  has_secure_password
  has_one_attached :avatar
  has_many :microposts, dependent: :destroy
  has_many :active_relationships, class_name: 'Relationship', foreign_key: 'follower_id', dependent: :destroy
  has_many :followings, through: :active_relationships, source: :followed
  has_many :passive_relationships, class_name: 'Relationship', foreign_key: 'followed_id', dependent: :destroy
  has_many :followers, through: :passive_relationships, source: :follower
  has_many :memberships, dependent: :destroy
  has_many :conversations, through: :memberships, dependent: :destroy
  has_many :messages, dependent: :destroy
  before_save :downcase_email
  before_create :create_activation_digest
  validates :name, presence: true, length: { maximum: 50 }, uniqueness: true, format: { without: /\s/, message: "can't contain spaces" }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email,
                presence: true,
                length: { maximum: 255 },
                format: { with: VALID_EMAIL_REGEX },
                uniqueness: true
  validates :password, length: { minimum: 6 }, presence: true, allow_nil: true

  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost

    BCrypt::Password.create(string, cost: cost)
  end

  def User.new_token
    SecureRandom.urlsafe_base64
  end

  def User.ransackable_attributes(auth_object = nil)
    ["name"]
  end

  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
    remember_digest
  end

  def session_token
    remember_digest || remember
  end

  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  def forget
    update_attribute(:remember_digest, nil)
  end

  def activate
    update_columns(activated: true, activated_at: Time.zone.now)
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def create_reset_digest
    self.reset_token = User.new_token
    update_columns(reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now)
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  def feed
    following_ids = "SELECT followed_id FROM relationships WHERE follower_id = :user_id"
    Micropost.where("user_id IN (#{following_ids}) OR user_id = :user_id OR in_reply_to LIKE :name", user_id: id, name: "%#{self.name}%")
             .includes(:user, image_attachment: :blob)
  end

  def follow(other_user)
    if other_user.notice?
      UserMailer.be_followed(self, other_user).deliver_now
    end

    followings << other_user unless self == other_user
  end

  def unfollow(other_user)
    followings.delete(other_user)
  end

  def following?(other_user)
    followings.include?(other_user)
  end

  def default_image_attache
    file = File.open(Rails.root.join('app', 'assets', 'images', 'jouba_pony_boy.png').to_s)
    avatar.attach(io: file, filename: 'jouba_pony_boy.png', content_type: 'image/png')
  end

  def create_conversation_with(other_user)
    conversation = Conversation.new
    ActiveRecord::Base.transaction do
      conversation.save!
      Membership.create!([
        { conversation: conversation, user: self },
        { conversation: conversation, user: other_user }
      ])
    end
    conversation
  end

  def get_conversation_with(other_user)
    conversation = conversations & other_user.conversations
    conversation[0]
  end

  def get_target_user(conversation)
    user = conversation.users.find { |user| user != self }
  end

  private

  def downcase_email
    self.email = email.downcase
  end

  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest(activation_token)
  end
end
