require 'rails_helper'

describe BreakingNews, type: :model do
  let(:breaking_news) { create(:breaking_news) }

  describe ".changing_status" do
    context "when trending until is nil" do
      before { breaking_news.disable! }

      it do
        expect(breaking_news).to receive(:disable!)
        breaking_news.change_status
      end
    end

    context "when trending until is NOT nil" do
      it do
        expect(breaking_news).to receive(:enable!)
        breaking_news.change_status
      end
    end
  end

  describe ".enable!" do
    it "disables othes breaking news" do
      expect(BreakingNews).to receive(:disable_all!).twice
      breaking_news.enable!
    end

    it "schedules removal from trending" do
      expect(breaking_news).to receive(:schedule_removal)
      breaking_news.enable!
    end

    it "publishes breaking news to users" do
      expect(breaking_news).to receive(:publish_update_message)
      breaking_news.enable!
    end
  end

  describe ".disable!" do
    it "resets trending until" do
      breaking_news.disable!
      expect(breaking_news.trending_until).to be_nil
    end

    it "removes scheduled removal from trending" do
      expect(breaking_news).to receive(:unschedule_removal)
      breaking_news.disable!
    end
  end

  describe ".disable_all!" do
    let!(:breaking_news_array) { create_list(:breaking_news, 2) }

    it do
      expect_any_instance_of(BreakingNews).to receive(:disable!)
      BreakingNews.disable_all!
    end
  end
end
