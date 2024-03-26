class ConversationsController < ApplicationController
  before_action :logged_in_user, only: [:index, :show]
  before_action :only_member, only: [:show]

  def index
    @conversations = current_user.conversations
  end

  def show
    @conversation = Conversation.find(params[:id])
    @messages = @conversation.messages.recent
    @message = Message.new
    @user = current_user.get_target_user(@conversation)
  end

  private

  def only_member
    @conversation = Conversation.find(params[:id])
    redirect_to(root_url, status: :see_other) unless @conversation.member?(current_user)
  end
end
