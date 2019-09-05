require 'rails_helper'

describe Trendable do

  describe ".schedule_removal_from_trending", vcr: { cassette_name: 'google_image_search' } do
    pending
    # it do
    #   trendable = create(:uncategorized_general_news_item, position: 1)
    #   expect(GeneralNewsItemWorker).to receive(:perform_at)
    #   trendable.schedule_removal_from_trending
    #   expect(GeneralNewsItemWorker.jobs.size).to be_eql(1)
    # end
  end
end
