require 'spec_helper'

describe "Authentication" do
  subject { page }

  # Signin Tests
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

      it { should have_title(user.name) }                             # Test to know if the user's profile page was rendered via the title "user.name"
      it { should have_link('Users',    href: users_path) }           # Test for the “Users” link URI.
      it { should have_link('Profile', href: user_path(user)) }       # Test for the appearance of a link to the profile page
      it { should have_link('Settings', href: edit_user_path(user)) } # Tests for a Settings link, checking that the user exists in the Database
      it { should have_link('Sign out', href: signout_path) }         # Test for the appearance of a “Sign out” link

      it { should_not have_link('Sign in', href: signin_path) }       # Test for the disappearance of the “Sign in” link


      describe "followed by signout" do                              # A test for signing out a user.
        before { click_link "Sign out" }
        it { should have_link('Sign in') }
      end

    end
  end

  # Testing that the edit and update actions are protected.
  describe "Authorization" do

    # A test for protecting the destroy action.
    describe "as a non-admin user" do
      let(:user) { FactoryGirl.create(:user) }
      let(:non_admin) { FactoryGirl.create(:user) }

      before { sign_in non_admin }

      describe "submitting a DELETE request to the Users#destroy action" do
        before { delete user_path(user) }
        specify { response.should redirect_to(root_path) }
      end

    end

    describe "for non-signed-in users" do
      let(:user) { FactoryGirl.create(:user) }

      # Access control tests for microposts.
      describe "in the Microposts controller" do

        describe "submitting to the create action" do
          before { post microposts_path }
          specify { response.should redirect_to(signin_path) }
        end

        describe "submitting to the destroy action" do
          before { delete micropost_path(FactoryGirl.create(:micropost)) }
          specify { response.should redirect_to(signin_path) }
        end

      end

      # Test for friendly forwarding.
      describe "when attempting to visit a protected page" do
        before do
          visit edit_user_path(user)
          fill_in "Email",    with: user.email
          fill_in "Password", with: user.password
          click_button "Sign in"
        end

        describe "after signing in" do
          it "should render the desired protected page" do
            page.should have_title('Edit user')
          end
        end

      end

      describe "in the Users controller" do

        describe "visiting the edit page" do
          before { visit edit_user_path(user) }
          it { should have_title('Sign in') }
        end

        describe "submitting to the update action" do
          before { put user_path(user) }                               # This issues a PUT request directly to /users/1, which gets routed to the update action of the Users controller. The only way to test the proper authorization for the update action itself is to issue a direct request.
          specify { response.should redirect_to(signin_path) }         # "Response" lets us test for the server response itself, in this case verifying that the update action responds by redirecting to the signin page
        end

        # Testing that the index action is protected.
        describe "visiting the user index" do
          before { visit users_path }
          it { should have_title('Sign in') }
        end

      end

    end

    # Testing that the edit and update actions require the right user.
    describe "as wrong user" do
      let(:user) { FactoryGirl.create(:user) }
      let(:wrong_user) { FactoryGirl.create(:user, email: "wrong@example.com") }
      before { sign_in user }

      describe "visiting Users#edit page" do
        before { visit edit_user_path(wrong_user) }
        it { should_not have_title(full_title('Edit user')) }
      end

      describe "submitting a PUT request to the Users#update action" do
        before { put user_path(wrong_user) }
        specify { response.should redirect_to(root_path) }
      end

    end

  end

end
