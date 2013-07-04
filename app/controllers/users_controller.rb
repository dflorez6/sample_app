class UsersController < ApplicationController
  def show                          # Show action
    @user = User.find(params[:id])
  end

  def new                           # New action
    @user = User.new
  end

  def create                        # Create action
    @user = User.new(params[:user])
    if @user.save
      flash[:success] = "Welcome to the Sample App!"  # Flash message if signup is successful
      redirect_to @user             # Redirects to the user's show page
    else
      render 'new'                  # Renders "new" view with error message when signup fails due to invalid info
    end
  end
end
