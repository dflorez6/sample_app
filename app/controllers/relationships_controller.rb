class RelationshipsController < ApplicationController
  before_filter :signed_in_user                                           # Only signedin users can follow (create) or unfollow (destroy) other_user.

  def create
    @user = User.find(params[:relationship][:followed_id])
    current_user.follow!(@user)
    respond_to do |format|                                               # This code uses respond_to to take the appropriate action depending on the kind of request. There is no relationship between this respond_to and the respond_to used in the RSpec examples.
      format.html { redirect_to @user }
      format.js
    end
  end

  def destroy
    @user = Relationship.find(params[:id]).followed
    current_user.unfollow!(@user)
    respond_to do |format|                                               # This code uses respond_to to take the appropriate action depending on the kind of request. There is no relationship between this respond_to and the respond_to used in the RSpec examples.
      format.html { redirect_to @user }
      format.js
    end
  end
end
