require 'spec_helper'

describe "UserPages" do

  subject { page }

  describe "signup page" do
    before { visit signup_path }

    it { should have_selector('h1',    text: 'Sign up') }
    it { should_not have_selector('title', text: full_title('Sign up')) }

  end

  # Using Factory Girl
  describe "profile page" do
    let(:user) { FactoryGirl.create(:user) }

    before { visit user_path(user) }

    it { should have_selector('h1',    text: user.name) }
    it { should_not have_selector('title', text: user.name) }
  end

  describe "signup" do

    before { visit signup_path }

    let(:submit) { "Create my account" }

    describe "with invalid information" do
      it "should not create a user" do
        expect { click_button submit }.not_to change(User, :count)
      end

      describe "after submission" do
        before { click_button submit }

        it { should have_selector('title', text: 'Sign up') }
        it { should have_content('error') }

        it "should contain error messages" do
          empty_user = User.new
          empty_user.save
          empty_user.errors.full_messages.each do |message|
            should have_content(message)
          end
        end
      end
    end

    describe "with valid information" do
      before do
        fill_in "Name",         with: "Example User"
        fill_in "Email",        with: "user@example.com"
        fill_in "Password",     with: "foobar"
        fill_in "Confirmation", with: "foobar"
      end

      it "should create a user" do
        expect { click_button submit }.to change(User, :count).by(1)
      end

      describe "after saving the user" do                    # Tests for the post-save behavior in the create action
        before { click_button submit }
        let(:user) { User.find_by_email('user@example.com') }

        it { should have_title(full_title(user.name)) }
        it { should have_selector('div.alert.alert-success', text: 'Welcome') }
      end

    end
  end

end
