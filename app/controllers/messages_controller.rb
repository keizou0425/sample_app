class MessagesController < ApplicationController
  def create
    @user = User.find(params[:target_id])
    @conversation = Conversation.find_or_create_conversation(current_user, @user)
    @message = current_user.messages.build(
      content: params[:message][:content],
      conversation: @conversation
    )

    if @message.save
      flash[:success] = 'Your message has been sent.'
      redirect_back fallback_location: root_path
    else
      resouces = request.referer.match(/(conversations|users)/)[0]
      if resouces == 'conversations'
        @messages = @conversation.messages.recent
      else
        @microposts = @user.microposts.paginate(page: params[:page])
      end
      render "#{resouces}/show", status: :unprocessable_entity
    end
  end
end
