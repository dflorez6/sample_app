
FactoryGirl.define do
  factory :user do
    sequence(:name)  { |n| "Person #{n}" }
    sequence(:email) { |n| "person_#{n}@example.com"}
    password "foobar"
    password_confirmation "foobar"

    factory :admin do                         # Adding a factory for administrative users.
      admin true
    end
  end

  factory :micropost do                      # Adding a factory for microposts.
    content "Lorem ipsum"
    user
  end
end