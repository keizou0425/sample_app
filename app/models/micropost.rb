class Micropost < ApplicationRecord
  belongs_to :user
  has_one_attached :image do |attachable|
    attachable.variant :display, resize_to_limit: [500, 500]
  end
  default_scope -> { order(created_at: :desc) }
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  validates :image, content_type: { in: %w[image/jpeg image/gif image/png], message: 'must be a valid image format' }, size: { less_than: 5.megabytes, message: 'should be less than 5MB' }


  def pick_out_reply
    replies = []
    str = content.gsub(/\n/, '')
    str.gsub(/@(\w+)/) do |match|
      user = User.find_by(name: $1)
      if user
        replies << user.name
      end
    end
    replies
  end
end
