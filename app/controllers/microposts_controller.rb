class MicropostsController < ApplicationController
  # ============
  # Filters
  # ============
  before_filter :signed_in_user, only: [:create, :destroy]
  before_filter :correct_user,   only: :destroy

  # ============
  # Actions
  # ============

  def create                                                          # The Microposts controller create action.
    @micropost = current_user.microposts.build(params[:micropost])
    if @micropost.save
      flash[:success] = "Micropost created!"
      redirect_to root_url
    else
      @feed_items = []                                                # Adding an (empty) @feed_items instance variable to the create action.
      render 'static_pages/home'
    end
  end

  def destroy                                                         # The Microposts controller destroy action.
    @micropost.destroy
    redirect_to root_url
  end

  private
    def correct_user
      @micropost = current_user.microposts.find_by_id(params[:id])    # This automatically ensures that we find only microposts belonging to the current user.
    rescue
      redirect_to root_url
    end

end