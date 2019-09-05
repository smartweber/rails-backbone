require 'rails_helper'

describe Company, type: :model do
  let!(:company) { create(:company, abbr: 'aapl') }

  describe ".latest_news", vcr: { cassette_name: 'yahoo_finance' } do
    context "when there's recent news items in DB" do
      let!(:recent_cni) { create(:company_news_item, company: company) }
      before { allow(company).to receive(:last_fetched_news_at).and_return(30.minutes.ago) }

      it "does NOT fetch news if it's already done recently" do
        recent_cni.company.latest_news
        expect_any_instance_of(Company).not_to receive(:fetch_latest_news)
      end
      it "does not create new records(as result of fetching)" do
        expect{company.latest_news}.not_to change(CompanyNewsItem, :count)
      end
    end

    context "when there's NO recent news items in DB" do
      let!(:outdated_cni) { create(:company_news_item, published_at: 2.hours.ago, company: company) }
      it "fetches news" do
        expect(company).to receive(:fetch_latest_news)
        company.latest_news
      end
    end

    context do
      let!(:recent_cni) { create(:company_news_item, company: company) }
      before { allow(company).to receive(:last_fetched_news_at).and_return(30.minutes.ago) }

      it "returns latest news items" do
        expect(company.latest_news.to_a).to be_eql([recent_cni])
      end
    end
  end

  describe "#autocomplete_by_abbr" do
    let!(:another_company) { create(:company, abbr: 'a') }
    let!(:popular_company) { create(:company, abbr: 'aabp', market_cap: 70000000) }
    let!(:not_relevant_company) { create(:company, abbr: 'bp', market_cap: 90000000, name: 'Not relevant' ) }

    it "isn't returning not relevant companies" do
      expect(Company.autocomplete_by_abbr('a').results).not_to include(not_relevant_company)
    end
    it "returns companies with exact matches first" do
      expect(Company.autocomplete_by_abbr('a').first).to be_eql(another_company)
    end
    it "returns companies with higher market_caps second" do
      expect(Company.autocomplete_by_abbr('a')[1]).to be_eql(popular_company)
    end
  end

  describe ".fetch_latest_news", vcr: { cassette_name: 'yahoo_finance' } do

    context "when no DB news found" do
      before { allow(company).to receive(:last_news_item_published_at).and_return(1.year.ago) }
      it "creates news items if there's no previous news at DB" do
        expect{company.send(:fetch_latest_news)}.to change(CompanyNewsItem, :count).by(10)
      end
    end
    context "when DB news are outdated" do
      before { allow(company).to receive(:last_fetched_news_at).and_return(61.minutes.ago) }
      before { allow(company).to receive(:last_news_item_published_at).and_return(1.year.ago) }

      it "creates news items for new ones" do
        expect{company.send(:fetch_latest_news)}.to change(CompanyNewsItem, :count).by(10)
      end
    end
  end

  describe "callbacks" do
    let!(:default_company) { create(:company, abbr: Company::DEFAULT_ORDER.keys.first) }
    let(:company) { create(:not_trending_company) }
    let(:trending_company) { create(:trending_company) }

    describe ".reposition" do
      context "moving company up in the list" do
        it do
          expect(company).to receive(:schedule_removal_from_trending)
          expect(company).to receive(:insert_at).with(1)
          company.update_attribute(:position, 1)
        end
        it "doesn't schedule DJ when self is a default company" do
          expect(company).not_to receive(:schedule_removal_from_trending)
          default_company.update_attribute(:position, 1)
        end
      end
      context "moving company down in the list" do
        it "updates trending_until" do
          expect{
            trending_company.update_attribute(:position, nil)
          }.to change(trending_company, :trending_until).to(nil)
        end
        it "moves default company back" do
          trending_company.update_attribute(:position, nil)
          expect(default_company.reload.position).to be_eql(1)
        end
      end
    end

    describe ".replace_with_default" do
      it "swaps positions between self and default for this position company" do
        trending_company.replace_with_default
        expect(default_company.reload.position).to be_eql(1)
        expect(trending_company.position).to be_eql(nil)
      end
    end

    describe ".set_default_trending_until" do
      it "sets default trending until if it's not being set before" do
        expect{
          company.update_attribute(:position, 1)
        }.to change(company, :trending_until)
      end
    end
  end
end
