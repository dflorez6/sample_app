class SessionsController < ApplicationController

  def new

  end

  def create
    user = User.find_by_email(params[:session][:email].downcase)      # Pulls the user out of the database using the submitted email address.
    if user && user.authenticate(params[:session][:password])         # if statement is true only if a user with the given email both exists in the database and has the given password
      sign_in user
      redirect_back_or user                                           # The Sessions "create" action with friendly forwarding, as it uses the redirect_back_or method.
    else
      flash.now[:error] = 'Invalid email/password combination'        # Create an error message. We use flash.now, which is specifically designed for displaying flash messages on rendered pages and dont let it persist.
      render 'new'                                                    #and re-render the signin form.
    end

  end

  def destroy
    sign_out
    redirect_to root_url
  end

end
