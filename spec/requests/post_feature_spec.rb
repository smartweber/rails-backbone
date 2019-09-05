require 'rails_helper'

RSpec.describe "Posts" do

  subject { page }

  let(:user) { FactoryGirl.create(:user) }
  let(:post) { create(:post, user: user) }

  before { sign_in user }

  describe "post creation" do
    before { visit root_path }

    describe "with invalid information" do

      it "should not create a post" do
        expect { click_button "Post" }.not_to change(Post, :count)
      end

      describe "error messages" do
        before { click_button "Post" }
        it { should have_content('error') }
      end
    end

    describe "with valid information" do

      before { fill_in 'post_content', with: "Lorem ipsum" }
      it "should create a post" do
        expect { click_button "Post" }.to change(Post, :count).by(1)
      end
    end
  end

  describe "when observed" do
    before { create_list(:comment, 4, commentable: post) }
    before { visit root_path }

    it "have only 3 comments visible" do
      Comment.last(3) do |c|
        expect(page).to have_content(c.body)
      end
      expect(page).not_to have_content(Comment.first.body)
    end
  end

  describe "post destruction" do
    before { FactoryGirl.create(:post, user: user) }

    describe "as correct user" do
      before { visit root_path }

      it "should delete a post" do
        expect { click_link "delete" }.to change(Post, :count).by(-1)
      end
    end
  end
end
