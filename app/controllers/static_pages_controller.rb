class StaticPagesController < ApplicationController
  def home
    @micropost = current_user.microposts.build if signed_in?          #  Adding a micropost instance variable to the home action.
    @feed_items = current_user.feed.paginate(page: params[:page])
  end

  def help
  end

  def about
  end

  def contact
  end
end
