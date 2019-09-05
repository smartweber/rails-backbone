require "rails_helper"

feature 'Relationships with', js: true do
  let!(:user) { FactoryGirl.create(:user) }
  before { sign_in_as user }

  context "users" do
    let!(:other_user) { FactoryGirl.create(:user) }

    context "from user page" do
      describe "following" do
        before { visit user_path(other_user) }

        it "hits database" do
          expect do
            click_link "Follow"
            wait_for_ajax
          end.to increment_follower_counters
        end
      end

      describe "unfollowing" do
        before do
          user.follow(other_user)
          visit user_path(other_user)
        end

        it "hits database" do
          expect do
            click_link "Unfollow"
            wait_for_ajax
          end.to decrement_follower_counters
        end
      end

      describe "toggling" do
        before { visit user_path(other_user) }

        it do
          within "#social-ui-region" do
            find('.bb-follow-user').click
            expect(page).to have_content("UNFOLLOW")
            find('.bb-follow-user').click
            expect(page).to have_content("FOLLOW")
          end
        end
      end
    end

    context "from autocomplete list" do
      before { visit command_path }
      before { @search_input = find('#autocomplete_search') }

      describe "following" do
        it "hits database" do
          expect do
            @search_input.native.send_keys(other_user.name.first(3))
            within ".tt-suggestions" do
              click_link 'Follow'
              wait_for_ajax
            end
          end.to increment_follower_counters
        end
      end

      describe "unfollowing" do
        before { user.follow(other_user) }

        it "hits database" do
          expect do
            @search_input.native.send_keys(other_user.name.first(3))
            within ".tt-suggestions" do
              click_link 'Unfollow'
              wait_for_ajax
            end
          end.to decrement_follower_counters
        end
      end
    end
  end

  context "companies", vcr: { cassette_name: 'company_page' } do
    let!(:company) { FactoryGirl.create(:company, abbr: 'AA') }

    describe "following" do
      before { visit company_path(company.abbr) }

      it "hits database" do
        expect do
          find('.track a').click
          wait_for_ajax
        end.to change(company.followers, :count).by(1)
      end
    end

    describe "unfollowing" do
      before { user.follow(company) }
      before { visit company_path(company.abbr) }

      it "hits database" do
        expect do
          find('.track a').click
          wait_for_ajax
        end.to change(company.followers, :count).by(-1)
      end
    end

    describe "toggling" do
      before { visit company_path(company.abbr) }

      it do
        click_link "Track"
        wait_for_ajax
        expect(page.body).to have_content("Untrack")
        click_link "Untrack"
        wait_for_ajax
        expect(page.body).to have_content("Track")
      end
    end
  end
end

def increment_follower_counters
  change(user.following_users, :count).by(1) and change(other_user.followers, :count).by(1)
end

def decrement_follower_counters
  change(user.following_users, :count).by(-1) and change(other_user.followers, :count).by(-1)
end
