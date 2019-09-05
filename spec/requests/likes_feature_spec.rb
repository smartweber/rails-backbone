require 'rails_helper'

RSpec.describe "Likes", type: :request, js: true do

  subject { page }

  let!(:comment) { create(:comment)}
  let(:user) { create(:user) }

  describe "when user clicks" do
    before { sign_in user }
    before { visit user_path(comment.commentable.user) }

    context "'like' button" do

      it "changes class to 'unlike'" do
        find('.comment .glyphicon-thumbs-up').click
        expect(page).to have_selector('.like-btn .glyphicon-thumbs-down')
        expect(page).not_to have_selector('.like-btn .glyphicon-thumbs-up')
      end
    end

    context "'unlike' button" do
      before { create(:like, likeable: comment, user: user) }
      before { visit user_path(comment.commentable.user) }

      it "changes class to 'like'" do
        find('.comment .glyphicon-thumbs-down').click
        expect(page).not_to have_selector('.like-btn .glyphicon-thumbs-down')
        expect(page).to have_selector('.like-btn .glyphicon-thumbs-up')
      end
    end

    describe "buttons" do

      it "increases and decreases corresponding counter" do
        find('.comment .glyphicon-thumbs-up').click
        expect(find('.comment .popularity-stats')).to have_content('1')
        find('.comment .glyphicon-thumbs-down').click
        expect(find('.comment .popularity-stats')).not_to have_content('0')
      end
    end
  end
end
