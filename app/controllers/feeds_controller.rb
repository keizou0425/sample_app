class FeedsController < ApplicationController
  def show
    @user = User.find(params[:user_id])
    @microposts = @user.microposts.limit(5)

    respond_to do |format|
      format.rss { render layout: false }
    end
  end
end
