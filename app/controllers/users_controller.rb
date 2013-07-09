class UsersController < ApplicationController
  before_filter :signed_in_user,  only: [:index, :edit, :update, :destroy]       # We restrict the before filter only to the edit and update actiones, otherwise it will apply to all of the controller actions.
  before_filter :correct_user,    only: [:edit, :update]                         # A correct_user before filter to protect the edit/update pages.
  before_filter :admin_user,      only: :destroy                                 # A before filter restricting the destroy action to admins.

  def show                          # Show action
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(page: params[:page])                 #  Adding an @microposts instance variable to the user show action.
  end

  def new                           # New action
    @user = User.new
  end

  def create                        # Create action
    @user = User.new(params[:user])
    if @user.save
      sign_in @user
      flash[:success] = "Welcome to the Sample App!"  # Flash message if signup is successful
      redirect_to @user                               # Redirects to the user's show page

    else
      render 'new'                                    # Renders "new" view with error message when signup fails due to invalid info
    end
  end

  def edit
    # @user is defined in :correct_user
  end

  def update
    if @user.update_attributes(params[:user])
      flash[:success] = "Profile updated"
      sign_in @user
      redirect_to @user
    else
      render 'edit'
    end
  end

  def index
    @users = User.paginate(page: params[:page])                       # Paginating the users in the index action.

  end

  def destroy                                                         # Adding a working destroy action.
    User.find(params[:id]).destroy
    flash[:success] = "User destroyed."
    redirect_to users_url
  end

  private
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_path) unless current_user?(@user)
    end

    def admin_user
      redirect_to(root_path) unless current_user.admin?
    end
end
