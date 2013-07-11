class Relationship < ActiveRecord::Base
  attr_accessible :followed_id                                   #  Note that, unlike the default generated Relationship model, in this case only the followed_id is accessible.

  # ============
  # Associations
  # ============

  # Adding the belongs_to associations to the Relationship model.
  belongs_to :follower, class_name: 'User'
  belongs_to :followed, class_name: 'User' # since there is neither a Followed nor a Follower model we need to supply the class name User.

  # ============
  # Validations
  # ============
  validates :follower_id, presence: true
  validates :followed_id, presence: true

end
