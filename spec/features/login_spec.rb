require 'rails_helper'

feature 'Log in' do
  given!(:user) { create(:user, email: 'user@example.com', password: 'password') }
  scenario 'with valid email and password', js: true do
    sign_in_with(email: 'user@example.com', password: 'password')
    expect(page).to have_content user.name
    expect(current_path).to eq command_path
  end
  scenario 'with invalid email and password', js: true do
    sign_in_with(email: 'user@example.com', password: 'invalid')
    expect(page).not_to have_content user.name
  end
end
