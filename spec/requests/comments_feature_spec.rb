require 'rails_helper'

RSpec.describe "Comments", type: :request, js: true do

  subject { page }

  let(:post) { FactoryGirl.create(:post) }

  describe "'See more comments' button" do
    before { @comments = create_list(:comment, 4, commentable: post) }
    before { sign_in post.user }

    describe "when clicked" do

      it "displays all comments" do
        click_on "See more comments"
        @comments.each do |c|
          expect(page).to have_content(c.body)
        end
      end

      it "hides itself" do
        click_on "See more comments"
        expect(page).not_to have_selector('.post .fetch-all-comments')
      end
    end
  end

  describe "creation" do
    before { sign_in post.user }

    context "with valid atrributes" do
      before do
        @sentence = Faker::Lorem.sentence
        within(".post") do
          click_on "reply"
          fill_in "Comment", with: @sentence
        end
      end

      it "creates comment" do
        expect { click_on "Create Comment" }.to change(Comment, :count).by(1)
      end

      it "adds comment on site" do
        click_on "Create Comment"
        expect(page).to have_content(@sentence)
      end
    end

    context "with invalid attributes" do
      it "isn't creating comment" do
        expect {
          within(".post") do
            click_on "reply"
            fill_in "Comment", with: ''
          end
          click_on "Create Comment"
        }.to change(Comment, :count).by(0)
      end
    end
  end

  describe "deletion" do
    before { create(:comment, commentable: post, user: post.user) }

    context "as comment creator" do
      before { sign_in post.user }
      before { visit root_path }

      it "allows deletion" do
        expect do
          within(".comment") do
            find(".glyphicon-remove").click
            page.driver.browser.switch_to.alert.accept
          end
        end.to change(Comment, :count).by(-1)
      end
    end

    context "as NOT comment creator" do
      before { sign_in create(:user) }
      before { visit user_path(post.user) }

      it "doesn't have delete link" do
        expect(page).not_to have_selector('.comment .glyphicon-remove')
      end
    end
  end
end
