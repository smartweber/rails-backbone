require 'rails_helper'

feature 'Likes', js: true do
  given!(:user) { create(:user, email: 'user@example.com', password: 'password') }

  background do
    sign_in_with(email: 'user@example.com', password: 'password')
    expect(page).to have_content user.name
    within '#form-content-region' do
      fill_in 'content', with: 'My Awesome Idea'
      click_link 'Share'
    end
    expect(page).to have_content 'My Awesome Idea'
  end

  # scenario 'creates like on a comment' do
  #   within '.reply-form-region' do
  #     fill_in 'Write a comment', with: 'My Awesome Comment'
  #   end
  #   find("[name='body']").native.send_keys(:Enter)
  #   expect(page).to have_content 'My Awesome Comment'
  #   expect(Comment.count).to eq 1
  #   find('.icon-thumbs-o-up').click
  #   expect(page).to have_content '1 people like this'
  #   expect(Like.count).to eq 1
  #   find('.icon-thumbs-o-down').click
  #   expect(page).to have_content '0 people like this'
  #   expect(Like.count).to eq 0
  # end

end
