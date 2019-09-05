require 'rails_helper'

describe GeneralNewsItemWorker, type: :model do

  describe ".remove_from_trending", vcr: { cassette_name: 'google_image_search' } do
    let!(:news_item) { create(:uncategorized_general_news_item, position: 1) }

    it "nullifies position" do
      GeneralNewsItemWorker.remove_from_trending(news_item.id)
      expect(news_item.reload.position).to be_nil
    end
  end
end
