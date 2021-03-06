module SessionsHelper
  def sign_in(user)
    cookies.permanent[:remember_token] = user.remember_token    # The cookies utility supplied by Rails.
    self.current_user = user                                    # The purpose of this line is to create current_user, accessible in both controllers and views. Without self, Ruby would simply create a local variable called current_user.
  end

  def signed_in?                                                # A user is signed in if there is a current user in the session, i.e., if current_user is non-nil. This requires the use of the “not” operator, written using an exclamation point !
    !current_user.nil?                                          # A user is signed in if current_user is not nil
  end

  def current_user=(user)                                       # Defining assignment to current_user.
    @current_user = user
  end

  def current_user                                              # Finding the current user using the remember_token.
    @current_user ||= User.find_by_remember_token(cookies[:remember_token])
  end

  def current_user?(user)
    user == current_user
  end

  def signed_in_user                                            # Moving the signed_in_user method into the Sessions helper
    unless signed_in?
      store_location                                            # Using friendly fordwarding
      redirect_to signin_url, notice: "Please sign in."
    end
  end

  def sign_out                                                  # We signout a user simply by setting the current user to nil and using the delete method on cookies to remove the remember token from the session
    self.current_user = nil
    cookies.delete(:remember_token)
  end

  # Code to implement friendly forwarding.
  def redirect_back_or(default)
    redirect_to(session[:return_to] || default)
    session.delete(:return_to)
  end

  def store_location
    session[:return_to] = request.url                             # We use the request object to get the url, i.e., the URI/URL of the requested page.
  end

end
