require 'rails_helper'

RSpec.describe ApplicationHelper do
  let(:user) { create(:user) }

  describe "full_title" do
    it "should include the page title" do
      expect(full_title("foo")).to match(/foo/)
    end

    it "should include the base title" do
      expect(full_title("foo")).to match(/Stockharp - Financial Platform for Business News, Stock Market, Quotes & Insights$/)
    end

    it "should not include a bar for the home page" do
      expect(full_title("")).not_to match(/\|/)
    end
  end

  describe "convert_specials_to_links" do
    before { @concatecated_name = user.username }

    it "returns argument if no special characters found" do
      expect(convert_specials_to_links('Karamba 2000')).to match(/^Karamba 2000$/)
    end

    context "mentions are" do
      it "wrapped into link" do
        expect(convert_specials_to_links('@' + @concatecated_name)).to match(/^<a/)
      end

      it "titleized" do
        expect(convert_specials_to_links('@' + @concatecated_name)).to match(/@#{user.titleized_name.gsub(' ','')}/)
      end

      it "not the same as input" do
        expect(convert_specials_to_links('@' + @concatecated_name)).not_to match(/^@#{@concatecated_name}$/)
      end
    end

    context "hashtags are" do
      it "not the same as input" do
        expect(convert_specials_to_links('#anything')).not_to match(/^#anything$/)
      end

      it "wrapped into link" do
        expect(convert_specials_to_links('#anything')).to match(/^<a/)
      end
    end
  end

  describe "link_to_username" do
    it "returns argument if no corresponding user found" do
      expect(link_to_username('@random')).to match(/random/)
    end

    it "wraps argument with a link if user found" do
      expect(link_to_username('@' + user.username)).to match(user_path(user))
    end
  end
end
