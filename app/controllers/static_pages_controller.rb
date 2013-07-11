class StaticPagesController < ApplicationController
  def home
    if signed_in?
<<<<<<< HEAD
      @micropost  = current_user.microposts.build                          #  Adding a micropost instance variable to the home action.
=======
      @micropost = current_user.microposts.build                      #  Adding a micropost instance variable to the home action.
>>>>>>> following-users
      @feed_items = current_user.feed.paginate(page: params[:page])
    end
  end

  def help
  end

  def about
  end

  def contact
  end


end
