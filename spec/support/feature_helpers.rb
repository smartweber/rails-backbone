include Warden::Test::Helpers

module Feature
  module Helpers
    def sign_in_with(email:, password:)
      visit new_user_session_path
      within ".box-login" do
        fill_in 'user[email]', :with => email
        fill_in 'user[password]', :with => password
        click_button 'Log in'
      end
    end

    def sign_in_as(user)
      login_as user, scope: :user
      user
    end
  end
end

