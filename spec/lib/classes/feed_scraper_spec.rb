require 'rails_helper'

RSpec.describe FeedScraper, :type => :model do
  let!(:old_feed) { double("Feedjira::Feed::Entry", published: 15.minutes.ago, summary: Faker::Lorem.sentence,
                                          title: Faker::Lorem.sentence, url: 'http://example.com/news/1') }
  let(:new_feed) { double("Feedjira::Feed::Entry", published: Time.now, summary: Faker::Lorem.sentence,
                                          title: Faker::Lorem.sentence, url: 'http://example.com/news/2') }
  let(:feeds) { {'http://example.com/rss' => double('Feedjira::Feed', entries: [old_feed, new_feed])} }
  let(:filtered_feeds) { {'http://example.com/rss' => double('Feedjira::Feed', entries: [new_feed])} }
  let(:malformed_feeds) { feeds.merge({ 'http://example2.com/rss' => 200 }) }

  let(:subject) do
    obj = described_class.new
    obj.feeds = feeds
    obj
  end

  describe "#fetch_news" do
    it "invokes Feedjira fetcher" do
      expect(Feedjira::Feed).to receive(:fetch_and_parse).exactly(15).times
      subject.send(:fetch_news)
    end
  end

  describe "#filter_outdated_news!" do
    let(:database_general_news_item) { double('GeneralNewsItem', created_at: 4.minutes.ago) }

    context "when 0 feeds in database" do
      it "isn't applying filter" do
        expect(subject.send(:filter_outdated_news!)).to be_eql(feeds)
      end
    end

    context "when MORE THAN 0 feeds in database" do
      # TODO: no sense
      it "filters argument based on published date" do
        expect(GeneralNewsItem).to receive(:last).and_return(database_general_news_item)
        expect(subject.send(:filter_outdated_news!).values.first.entries).to be_eql([new_feed])
      end
    end

    context "on malformed response" do
      let(:scrapper_with_malformed_data) do
        obj = described_class.new
        obj.feeds = malformed_feeds
        obj
      end

      it "isn't raising exception" do
        expect(GeneralNewsItem).to receive(:last).and_return(database_general_news_item)
        expect{scrapper_with_malformed_data.send(:filter_outdated_news!)}.not_to raise_exception
      end
    end
  end

  describe "#parse_feeds" do
    let(:invalid_feed_item) { double("Feedjira::Feed::Entry", published: Time.now, summary: 'Invalid',
                                          title: Faker::Lorem.sentence, url: 'http://example.com/news/2') }
    let(:invalid_feeds) { {'http://example.com/rss' => double('Feedjira::Feed', entries: [invalid_feed_item])} }

    before do
      subject.feeds = filtered_feeds
      subject.sources = { example_agency: 'http://example.com/rss' }
    end

    context "when new entity is valid" do
      it "invokes set_keywords! on new entity" do
        expect_any_instance_of(GeneralNewsItem).to receive(:set_keywords!)
        subject.send(:parse_feeds)
      end

      it "merges new entity to a hash" do
        expect{subject.send(:parse_feeds)}.to change(subject.not_saved_news, :size).by(1)
      end
    end

    context "when new entitiy is NOT valid" do
      before { subject.feeds = invalid_feeds }

      it "is NOT merging new entity to a hash" do
        expect{subject.send(:parse_feeds)}.not_to change(subject.not_saved_news, :size)
      end
    end
  end

  describe "#merge_keywords_from" do
    context "when argument is saved feed" do
      let(:saved_gni) { create(:uncategorized_general_news_item) }

      it "merges entity keywords to hash" do
        subject.send(:merge_keywords_from, saved_gni)
        expect(subject.keywords_hash.keys).to include(saved_gni.id)
      end
    end

    context "when argument is NOT saved feed" do
      let(:unsaved_gni) { build(:uncategorized_general_news_item) }

      it "merges entity keywords to hash" do
        subject.send(:merge_keywords_from, unsaved_gni)
        expect(subject.keywords_hash.keys).to include(unsaved_gni.object_id.to_s(16))
      end
    end

    context "when argument is feeds array" do
      let(:uncategorized_saved_news_items) { create_list(:uncategorized_general_news_item, 2) }

      it "merges every feed from it" do
        subject.send(:merge_keywords_from, uncategorized_saved_news_items)
        expect(subject.keywords_hash.keys).to be_eql(uncategorized_saved_news_items.map(&:id))
      end
    end
  end

  describe "#update_duplicates_refs" do
    let!(:outdated_news_item) { create(:general_news_item, created_at: 25.hours.ago) }
    let!(:categorized_general_news_item) { create(:categorized_general_news_item) }
    let!(:uncategorized_saved_news_item) { create(:uncategorized_general_news_item) }

    it "assigns one day old not categorized saved feeds" do
      subject.send(:update_duplicates_refs)
      expect(subject.saved_news).to be_eql([uncategorized_saved_news_item])
    end

    context "when best match is NOT associated with any NewsSubject" do
      let(:uncategorized_not_saved_gni) { build(:uncategorized_general_news_item) }

      before do
        best_match = { obj: uncategorized_not_saved_gni, distance: 0.5 }
        expect_any_instance_of(FeedScraper).to receive(:find_best_match_for)
                            .with(uncategorized_saved_news_item).and_return(best_match)
      end

      it "creates a news subject" do
        expect{subject.send(:update_duplicates_refs)}.to change(NewsSubject, :count).by(1)
      end

      it "saves new feed" do
        expect{subject.send(:update_duplicates_refs)}.to change(GeneralNewsItem, :count).by(1)
      end
    end

    context "when best match is associated with NewsSubject" do
      before do
        best_match = { obj: categorized_general_news_item, distance: 0.5 }
        expect_any_instance_of(FeedScraper).to receive(:find_best_match_for)
                                              .with(uncategorized_saved_news_item).and_return(best_match)
      end

      it "doesn't create a news subject" do
        expect{subject.send(:update_duplicates_refs)}.not_to change(NewsSubject, :count)
      end

      it "saves new feed" do
        expect{subject.send(:update_duplicates_refs)}.not_to change(GeneralNewsItem, :count)
      end
    end
  end

  describe "#find_best_match_for" do

    context "with unsaved feed" do
      let!(:unsaved_news_item) { feed = build(:uncategorized_general_news_item) }

      context "without matches" do
        it do
          subject.send(:merge_to_unsaved, unsaved_news_item)
          subject.send(:merge_keywords_from, unsaved_news_item)
          expect(subject.send(:find_best_match_for, unsaved_news_item)).to be_eql({
            obj: nil,
            distance: 1.0
          })
        end
      end

      context "with" do
        context "unsaved matches" do
          let!(:unsaved_matching_news_item) do
            gni = build(:uncategorized_general_news_item, stemmed_keywords: unsaved_news_item.stemmed_keywords)
            gni
          end
          before do
            [unsaved_news_item, unsaved_matching_news_item].each do |gni|
              subject.send(:merge_to_unsaved, gni)
              subject.send(:merge_keywords_from, gni)
            end
          end

          it "returns proper data" do
            expect(subject.send(:find_best_match_for, unsaved_news_item)).to be_eql({
              obj: unsaved_matching_news_item,
              distance: 0.0
            })
          end
        end

        context "saved matches" do
          let!(:saved_matching_feed) do
            gni = create(:uncategorized_general_news_item, stemmed_keywords: unsaved_news_item.stemmed_keywords)
            gni
          end
          before do
            [unsaved_news_item, saved_matching_feed].each do |gni|
              subject.send(:merge_to_unsaved, gni) unless gni.persisted?
              subject.send(:merge_keywords_from, gni)
            end
            subject.saved_news = [saved_matching_feed]
          end

          it "returns proper data" do
            expect(subject.send(:find_best_match_for, unsaved_news_item)).to be_eql({
              obj: saved_matching_feed,
              distance: 0.0
            })
          end
        end
      end
    end
  end
end
