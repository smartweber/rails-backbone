require 'rails_helper'

feature 'User signs up for new account', js: true do
  background do
    visit new_user_registration_path
  end
  scenario 'when some mandatory fields are missing' do
    within '#sign-up-form' do
      fill_in 'Full name', with: 'Ashish Bista'
      fill_in 'Username', with: 'ashishbista'
      fill_in 'Password', with: 'password'
      fill_in 'Password confirmation', with: 'password'
      click_button 'Sign Up'
    end
    expect(User.count).to be_zero
  end
  scenario 'when all mandatory fields are filled up' do
    within '#sign-up-form' do
      fill_in 'Full name', with: 'Ashish Bista'
      fill_in 'Username', with: 'ashishbista'
      fill_in 'Email', with: 'b@ashishbista.com'
      fill_in 'Password', with: 'password'
      fill_in 'Password confirmation', with: 'password'
      find("input[name='user[tos_and_pp_accepted]']").click
      click_button 'Sign Up'
    end
    expect(page).to have_content("Ashish Bista")
    expect(User.count).to eq 1
    expect(ActionMailer::Base.deliveries.last.to).to include 'b@ashishbista.com'
    expect(ActionMailer::Base.deliveries.last.subject).to eq nil
  end
end

