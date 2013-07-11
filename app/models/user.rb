# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  email           :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  password_digest :string(255)
#  remember_token  :string(255)
#  admin           :boolean          default(FALSE)
#


class User < ActiveRecord::Base
  attr_accessible :name, :email, :password, :password_confirmation
  has_secure_password
  has_many :microposts, dependent: :destroy                                           # Ensuring that a user’s microposts are destroyed along with the user.
 # Implementing the user/relationships has_many association. Explicitly declaring the foreign key that allows Rails to make the association
  has_many :relationships, foreign_key: 'follower_id',
                            dependent: :destroy
 #  Adding the User model followed_users association. Rails allows us to override the default, in this case using the :source parameter, which explicitly tells Rails that the source of the followed_users array is the set of followed ids.
  has_many :followed_users, through: :relationships,
                            source: :followed
  # Implementing user.followers using reverse relationships.
  has_many :reverse_relationships, foreign_key: "followed_id",                        # We actually have to include the class name for this association, because otherwise Rails would look for a ReverseRelationship class.
                                   class_name:  "Relationship",
                                   dependent:   :destroy
  has_many :followers, through: :reverse_relationships                               # We could omit the :source key in this case since, in the case of a :followers attribute, Rails will singularize “followers” and automatically look for the foreign key follower_id in this case.


  before_save { email.downcase! }                                                     # Makes sure the email address is lower cased before being saved
  before_save :create_remember_token                                                  # A before_save callback to create remember_token.

  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence:   true,
            format:     { with: VALID_EMAIL_REGEX },
            uniqueness: { case_sensitive: false }
  validates :password, presence: true, length: { minimum: 6 }           # Prescence and length validation for the password
  validates :password_confirmation, presence: true
  after_validation { self.errors.messages.delete(:password_digest) }    # Remove the “Password digest can’t be blank” error message

  def feed
    Micropost.from_users_followed_by(self)                              # Adding the completed feed to the User model.
  end

  # The following? utility method.
  def following?(other_user)
    self.relationships.find_by_followed_id(other_user.id)               # The following? method takes in a user, called other_user, and checks to see if a followed user with that id exists in the database
  end

  # The follow! utility method.
  def follow!(other_user)
    self.relationships.create!(followed_id: other_user.id)              # The follow! method calls create! through the relationships association to create the following relationship.
  end

  # Unfollowing a user by destroying a user relationship.
  def unfollow!(other_user)
    self.relationships.find_by_followed_id(other_user.id).destroy
  end



  # All methods defined in a class after private are automatically hidden
  private

    def create_remember_token
      self.remember_token = SecureRandom.urlsafe_base64
    end

end
