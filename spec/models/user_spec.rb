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

require 'spec_helper'

describe User do

  before do                                                                       # Initialization hash
    @user = User.new(name: "Example User", email: "user@example.com",
                     password: "foobar", password_confirmation: "foobar")
  end

  subject { @user }

  it { should respond_to(:name)}
  it { should respond_to(:email) }
  it { should respond_to(:password_digest) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:remember_token) }           # Test for authentication token that will persist
  it { should respond_to(:admin) }                    # Test for admin user
  it { should respond_to(:authenticate) }
  it { should respond_to(:microposts) }               #  A test for the user’s microposts attribute.
  it { should respond_to(:feed) }
  it { should respond_to(:relationships) }            # Testing for the user.relationships attribute.
  it { should respond_to(:followed_users) }           # A test for the user.followed_users attribute.
  it { should respond_to(:reverse_relationships) }    # Reversed table based on the relationships table
  it { should respond_to(:followers) }
  it { should respond_to(:following?) }
  it { should respond_to(:follow!) }                  # We add an associated following? boolean method to test if one user is following another.
  it { should respond_to(:unfollow!) }


  it { should be_valid }
  it { should_not be_admin }

  # Tests for an admin attribute.
  describe "with admin attribute set to 'true'" do
    before do
      @user.save!
      @user.toggle!(:admin)                           # Here we’ve used the toggle! method to flip the admin attribute from false to true
    end

    it { should be_admin }
  end

  describe "when name is not present" do              # Presence Validation (checks for a non_blank name)
    before { @user.name = "" }
    it { should_not be_valid }
  end

  describe "when email is not present" do             # Presence Validation (checks for a non_blank email)
    before { @user.email = "" }
    it { should_not be_valid }
  end

  describe "when name is too long" do                 # Length Validation
    before { @user.name = "a" * 51 }
    it { should_not be_valid }
  end

  # Tests for name validations
  describe "when email format is invalid" do    # Email Format Validation
    it "should be invalid" do
      addresses = %w[user@foo,com user_at_foo.org example.user@foo.
                     foo@bar_baz.com foo@bar+baz.com]
      addresses.each do |invalid_address|
        @user.email = invalid_address
        @user.should_not be_valid
      end
    end
  end

  describe "when email format is valid" do      # Email Format Validation
    it "should be valid" do
      addresses = %w[user@foo.COM A_US-ER@f.b.org first.lst@foo.jp a+b@baz.cn]
      addresses.each do |valid_address|
        @user.email = valid_address
        @user.should be_valid
      end
    end
  end

  describe "when email address is already taken" do   # Email Uniqueness Validation
    before do
      user_with_same_email = @user.dup                   # Creates a duplicate user with the same attributes
      user_with_same_email.email = @user.email.upcase    # A test for the rejection of duplicate email addresses, insensitive to case.
      user_with_same_email.save                          # For this validation you must actually insert an object into the database
    end
    it { should_not be_valid }
  end

  describe "email address with mixed case" do
    let(:mixed_case_email) { "Foo@ExAMPle.CoM" }

    it "should be saved as all lower-case" do
      @user.email = mixed_case_email
      @user.save
      @user.reload.email.should == mixed_case_email.downcase
    end
  end

  # Tests for password validations
  describe "when password is not present" do               # We only need to test the case of a mismatch
    before { @user.password = @user.password_confirmation = " " }
    it { should_not be_valid }
  end

  describe "when password doesn't match confirmation" do
    before { @user.password_confirmation = "mismatch" }
    it { should_not be_valid }
  end

  describe "when password confirmation is nil" do
    before { @user.password_confirmation = nil }
    it { should_not be_valid }
  end

  describe "with a password that's too short" do
    before { @user.password = @user.password_confirmation = "a" * 5 }
    it { should be_invalid }
  end

  # Test for authentication
  describe "return value of authenticate method" do
    before { @user.save }                                         # The before block saves the user to the database
    let(:found_user) { User.find_by_email(@user.email) }          # Let method provides a convenient way to create local variables inside tests

    describe "with valid password" do
      it { should == found_user.authenticate(@user.password) }     # “double equals” == test for object equivalence
    end

    describe "with invalid password" do
      let(:user_for_invalid_password) { found_user.authenticate("invalid") }

      it { should_not == user_for_invalid_password }
      specify { user_for_invalid_password.should be_false }
    end
  end

  # Test for remember_token
  describe "remember token" do                                     # A test for a valid (nonblank) remember token.
    before { @user.save }
    its(:remember_token) { should_not be_blank }                   # The its method, which is like it but applies the subsequent test to the given attribute rather than the subject of the test
    # it { @user.remember_token.should_not be_blank }              EQUIVALENT
  end

  # Testing the order of a user’s microposts.
  describe "micropost association" do

    before { @user.save }
    let!(:older_micropost) do                                                     # let! forces the corresponding variable to come into existence immediately.
      FactoryGirl.create(:micropost, user: @user, created_at: 1.day.ago)
    end
    let!(:newer_micropost) do                                                     # let! forces the corresponding variable to come into existence immediately.
      FactoryGirl.create(:micropost, user: @user, created_at: 1.hour.ago)
    end

    # Testing the right order that microposts are displayed
    it "should have the right micropost in the right order" do
      @user.microposts.should == [newer_micropost, older_micropost]               # Indicates that the posts should be ordered newest first.
    end

    # Testing that microposts are destroyed when users are.
    it "should destroy associated microposts" do
      microposts = @user.microposts.dup
      @user.destroy
      microposts.should_not be_empty
      microposts.each do |micropost|
        Micropost.find_by_id(micropost.id).should be_nil                          # Returns nil if the record is not found
      end
    end

    # Tests for the status feed.
    describe "status" do
      let(:unfollowed_post) do
        FactoryGirl.create(:micropost, user: FactoryGirl.create(:user))
      end
      let(:followed_user) { FactoryGirl.create(:user) }

      before do
        @user.follow!(followed_user)
        3.times { followed_user.microposts.create!(content: "Lorem ipsum") }
      end

      its(:feed) { should include(newer_micropost) }
      its(:feed) { should include(older_micropost) }
      its(:feed) { should_not include(unfollowed_post) }
      its(:feed) do                                                             # The final tests for the status feed
        followed_user.microposts.each do |micropost|
          should include(micropost)
        end
      end

    end


  end

  #  Tests for some “following” utility methods.
  describe "following" do
    let(:other_user) { FactoryGirl.create(:user) }
    before do
      @user.save
      @user.follow!(other_user)                                     # Utility method which we indicate with an exclamation point that an exception will be raised on failure.
    end

    it { should be_following(other_user) }
    its(:followed_users) { should include(other_user) }

    # Testing for reverse relationships.
    describe "followed user" do                                     # followed user ( == following, but != followers
      subject { other_user }                                        # We switch subjects using the subject method, replacing @user with other_user, allowing us to test the follower relationship in a natural way
      its(:followers) { should include(@user) }

    end

    # A test for unfollowing a user.
    describe "and unfollowing" do
      before { @user.unfollow!(other_user) }

      it { should_not be_following(other_user) }
      its(:followed_users) { should_not include(other_user) }

    end


  end


end


