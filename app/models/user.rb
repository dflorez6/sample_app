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
  has_many :microposts, dependent: :destroy                             # Ensuring that a user’s microposts are destroyed along with the user.

  before_save { email.downcase! }                                       # Makes sure the email address is lower cased before being saved
  before_save :create_remember_token                                    # A before_save callback to create remember_token.

  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence:   true,
            format:     { with: VALID_EMAIL_REGEX },
            uniqueness: { case_sensitive: false }
  validates :password, presence: true, length: { minimum: 6 }           # Prescence and length validation for the password
  validates :password_confirmation, presence: true
  after_validation { self.errors.messages.delete(:password_digest) }    # Remove the “Password digest can’t be blank” error message

  def feed
    # This is preliminary. See "Following users" for the full implementation.
    Micropost.where("user_id = ?", id)                                  # We can arrange for an appropriate micropost feed method by selecting all the microposts with user_id equal to the current user’s id, which we accomplish using the where method on the Micropost mode
  end

  private     # All methods defined in a class after private are automatically hidden

    def create_remember_token
      self.remember_token = SecureRandom.urlsafe_base64
    end

end
