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
  it { should respond_to(:authenticate) }
  it { should respond_to(:admin) }                    # Test for admin user

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

  describe "remember token" do                                     # A test for a valid (nonblank) remember token.
    before { @user.save }
    its(:remember_token) { should_not be_blank }                   # The its method, which is like it but applies the subsequent test to the given attribute rather than the subject of the test
    # it { @user.remember_token.should_not be_blank }              EQUIVALENT
  end

end


