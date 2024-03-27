class FeedsController < ApplicationController
  def show
    @user = User.find(params[:user_id])
    @microposts = []
    @title = "#{@user.name}の投稿"
    @description = "#{@user.name}の最新の投稿"

    if params[:feed]
      @microposts = @user.feed.limit(5)
      @title.gsub!(/投稿/, 'フィード')
      @description.gsub!(/投稿/, 'フィード')
    else
      @microposts = @user.microposts.limit(5)
    end

    respond_to do |format|
      format.rss { render layout: false }
    end
  end
end
