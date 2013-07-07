require 'spec_helper'

describe "Authentication" do
  subject { page }

  describe "signin" do
    before { visit signin_path }

    describe "with invalid information" do
      before { click_button "Sign in" }         # Capybara Test
      it { should have_title('Sign in') }
      it { should have_selector('div.alert.alert-error', text: 'Invalid') }  # Test for invalid signin using a flash message

      describe "after visiting another page" do
        before { click_link "Home" }
        it { should_not have_selector('div.alert.alert-error') }
      end

    end

    describe "with valid information" do
      let(:user) { FactoryGirl.create(:user) }
      before do
        fill_in "Email",    with: user.email.upcase
        fill_in "Password", with: user.password
        click_button "Sign in"
      end

      it { should have_title(user.name) }                            # Test to know if the user's profile page was rendered via the title "user.name"
      it { should have_link('Profile', href: user_path(user)) }      # Test for the appearance of a link to the profile page
      it { should have_link('Sign out', href: signout_path) }        # Test for the appearance of a “Sign out” link
      it { should_not have_link('Sign in', href: signin_path) }      # Test for the disappearance of the “Sign in” link


      describe "followed by signout" do                              # A test for signing out a user.
        before { click_link "Sign out" }
        it { should have_link('Sign in') }
      end

    end
  end
end
