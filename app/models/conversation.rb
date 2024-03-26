class Conversation < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships, dependent: :destroy
  has_many :messages, dependent: :destroy

  def Conversation.find_or_create_conversation(user_1, user_2)
    conversation = user_1.get_conversation_with(user_2)
    conversation ||= user_1.create_conversation_with(user_2)
  end

  def member?(user)
    users.include?(user)
  end
end
