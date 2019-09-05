require 'rails_helper'

describe 'Feed', js: true do
  let!(:user) { create(:user, email: 'user@example.com', password: 'password') }
  before { sign_in_as user }

  context "at command page" do
    feature "post listing" do
      let(:other_user) { create(:user) }
      let!(:post1) { create(:post, user: user, content: "Foo") }
      let!(:post2) { create(:post, user: user, content: "Bar") }
      let!(:friends_only_post) { create(:post, user: user, friends_only: true) }

      context "as viewed by" do

        context "page owner" do
          before { visit user_path(user) }

          it { expect(page).to have_content(post1.content) }
          it { expect(page).to have_content(post2.content) }
          it { expect(page).to have_content(friends_only_post.content) }
          it { expect(page).to have_content(user.posts.count) }
        end

        context "NOT a page owner" do
          before { sign_in_as other_user }

          context "and NOT as friend" do
            before { visit user_path(user) }

            it { expect(page).to have_content(post1.content) }
            it { expect(page).to have_content(post2.content) }
            it { expect(page).not_to have_content(friends_only_post.content) }
          end

          context "and as friend" do
            before { user.follow(other_user) }
            before { other_user.follow(user) }
            before { visit user_path(user) }

            it { expect(page).to have_content(post1.content) }
            it { expect(page).to have_content(post2.content) }
            it { expect(page).to have_content(friends_only_post.content) }
          end
        end

        context "unregistered user" do
          before { logout }
          before { visit user_path(user) }

          it { expect(page).to have_content(post1.content) }
        end
      end
    end

    feature 'creating posts' do
      context "from command page" do
        background { visit command_path }

        scenario 'with valid inputs' do
          expect(page).to have_content user.name
          within '#form-content-region' do
            find('[name="post[content]"]').click
            fill_in 'post[content]', with: 'My Awesome Idea'
            click_link 'Share'
          end
          within '.feed-region' do
            expect(page).to have_content 'My Awesome Idea'
            expect(page).to have_content user.name.upcase
          end
          expect(Post.count).to eq 1
        end
      end
    end

    feature 'creating comments' do
      let(:valid_comment_body) { 'My Awesome Comment' }

      background do
        visit command_path
        expect(page).to have_content user.name
        within '#form-content-region' do
          find("[name='post[content]']").click
          fill_in 'post[content]', with: 'My Awesome Idea'
          click_link 'Share'
        end
        expect(page).to have_content 'My Awesome Idea'
      end

      scenario 'with valid input' do
        create_comment_with(valid_comment_body)
        expect(page).to have_content valid_comment_body
        expect(Comment.count).to eq 1
      end

      scenario 'with invalid input' do
        create_comment_with('a')
        expect(page).to have_content 'short (minimum is 3 characters)'
        expect(Comment.count).to eq 0
      end

      def create_comment_with(value)
        within '.bb-reply-form' do
          fill_in 'Write a comment', with: value
        end
        find("[name='comment[body]']").native.send_keys(:Enter)
      end
    end
  end

  context "at company page", vcr: { cassette_name: 'company_page' } do
    let!(:company) { create(:company, abbr: 'AA') }

    describe "posts section" do
      before { @post = create(:post, content: "$EXPL $#{company.abbr}") }
      before { @private_post = create(:post, content: "Top secret info about #{company.abbr}", friends_only: true) }
      before { visit(company_path(company.abbr)) }

      it "displays posts with company mentions" do
        expect(page).to have_content(@post.content.upcase)
      end

      it "doesn't display friends-only posts with company mentions" do
        expect(page).not_to have_content(@private_post.content)
      end

      it "auto appends company tag into post" do
        element = find("[name='post[content]']")
        find("[name='post[content]']").click
        expect(element.value()).to be_eql("$#{company.abbr.upcase} ")
      end
    end
  end
end
