require 'rails_helper'

feature "Autocomplete", js: true do

  context "as signed in user" do
    let!(:user) { create(:user) }
    before { sign_in_as user }

    context "when user types" do
      before { visit root_path }
      before do
        @search_input = find('#autocomplete_search')
        @search_input.click
      end

      context "anything relevant" do
        let!(:user) { create(:user, name: 'Great Name') }
        let!(:company) { create(:company, abbr: user.name.first(3).upcase) }
        before do
          @search_input.native.send_keys(user.name.first(3))
        end

        it "shows all relevant results" do
          within('.twitter-typeahead') do
            expect(page).to have_content(user.name)
            expect(page).to have_content(company.abbr)
          end
        end
      end

      context "user name" do
        let!(:user) { create(:user) }
        before do
          @search_input.native.send_keys(user.name.first(4))
        end

        it "shows variants" do
          within('.tt-suggestion') do
            expect(page).to have_content(user.name)
          end
        end

        context "and selects found user suggestion with 'Enter' key" do

          it "redirects to user page" do
            #just a manual wait-until-visible
            find('.tt-suggestion')
            @search_input.native.send_keys(:Down)
            expect(find('.tt-cursor')).not_to be nil
            @search_input.native.send_keys(:Return)
            expect(current_path).to be_eql user_path(user)
          end
        end
      end

      context "company abbreviation" do
        before { @company = create(:company) }
        before { @search_input.native.send_keys(@company.abbr.first(2)) }
        around { |ex| VCR.use_cassette("company_page", &ex) }

        it "shows variants" do
          within('.tt-dataset-companies .tt-suggestion') do
            expect(page).to have_content(@company.name)
          end
        end

        it "redirects to company page when option is selected" do
          #just a manual wait-until-visible
          find('.tt-suggestion')
          @search_input.native.send_keys(:Down)
          expect(find('.tt-cursor')).not_to be nil
          @search_input.native.send_keys(:Return)
          expect(current_path).to be_eql company_path(@company.abbr)
        end
      end
    end
  end

  context "as a guest" do
    context "at landing page" do
      before { visit root_path }

      it "no autocomplete field is visible" do
        expect(page).to have_selector('#autocomplete_search')
      end
    end

    context "at signup page" do
      before { visit signup_path }

      it "no autocomplete field is visible" do
        expect(page).not_to have_selector('#autocomplete_search')
      end
    end
  end
end
