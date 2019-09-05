require 'rails_helper'

RSpec.describe GeneralNewsItem, type: :model do
  let(:news_item) { create(:uncategorized_general_news_item, agency: :washington_post) }

  subject { described_class.new }

  describe "set_keywords!" do

    it "sets keywords attribute" do
      news_item.set_keywords!
      expect(news_item.stemmed_keywords.size).not_to be_zero
      expect(news_item.not_stemmed_keywords.size).not_to be_zero
    end
  end

  describe ".title_keywords" do

    it "returns not empty keywords array" do
      expect(news_item.title_keywords.length).not_to be_zero
    end
  end

  describe ".summary_keywords" do

    it "returns not empty keywords array" do
      expect(news_item.title_keywords.length).not_to be_zero
    end
  end

  describe ".partially_downcased_summary" do

    it "downcases each first word in a sentence" do
      expect(news_item.partially_downcased_summary[0]).to match(/[a-z]/)
    end

    it "uses sanitized summary" do
      news_item['summary'] = "Text <a href='#'>Link</a>"
      expect(news_item.partially_downcased_summary).to eq('text Link')
    end
  end

  describe ".sanitize_body" do

    it "replaces commong agencies junk occurencies in summaries" do
      expect do
        news_item.summary = 'Some summary text here. Read full article >>'
        news_item.save
      end.to change(news_item, :summary).to('Some summary text here.')
    end

    it "strips tags" do
      expect do
        news_item.summary = 'Some summary <script>evil</script> text here. Read full article >>'
        news_item.save
      end.to change(news_item, :summary).to('Some summary evil text here.')
    end
  end

  describe ".title=" do

    it "strips tags" do
      expect{ news_item.title = 'Some title <script>evil</script> text here.' }
        .to change(news_item, :title).to('Some title evil text here.')
    end
  end

  describe "#keywords_from_content" do

    it "returns array" do
      expect(GeneralNewsItem.keywords_from_content(news_item.summary) do
        set :stemming, true
      end).to be_instance_of(Highscore::Keywords)
    end
  end

  describe "#with_positions_between", vcr: { cassette_name: 'google_image_search' } do
    let!(:positioned_news) { create_list(:positioned_general_news_item, 2) }
    let!(:not_positioned_news_item) { create(:uncategorized_general_news_item) }

    it "returns both already positioned and newly positioned records" do
      expect(GeneralNewsItem.with_positions_between(1, 3)).to be_eql(positioned_news + [not_positioned_news_item])
    end
  end

  describe "#get_additional_news", vcr: { cassette_name: 'google_image_search' } do
    let!(:gni_arr) { create_list(:general_news_item, 3) }

    it "returns exact amount of records" do
      expect(GeneralNewsItem.get_additional_news(2)).to be_eql(gni_arr[0..1])
    end
  end

  describe "#prepare_additional_news", vcr: { cassette_name: 'google_image_search' } do
    let!(:not_positioned_news_item) { create_list(:uncategorized_general_news_item, 2) }
    let!(:positioned_news) { create_list(:positioned_general_news_item, 3) }
    let!(:last_positioned_news_item) { create(:uncategorized_general_news_item, position: 5) }
    let!(:all_positioned_news) { positioned_news + [last_positioned_news_item] }

    it "returns additional news items" do
      expect(GeneralNewsItem.prepare_additional_news(all_positioned_news, 1, 5)).to be_eql([not_positioned_news_item.first])
    end

    it "sets appropriate positions to newly found news items" do
      expect(GeneralNewsItem).to receive(:get_additional_news).and_return([not_positioned_news_item.first])
      GeneralNewsItem.prepare_additional_news(all_positioned_news, 1, 5)
      expect(not_positioned_news_item.first.reload.position).to be_eql(4)
    end

    it "sets trending_until to end of the day" do
      expect(GeneralNewsItem).to receive(:get_additional_news).and_return([not_positioned_news_item.first])
      GeneralNewsItem.prepare_additional_news(all_positioned_news, 1, 5)
      expect(not_positioned_news_item.first.reload.trending_until).to be_eql(Time.new.tomorrow.at_beginning_of_day)
    end
  end

  context "repositioning", vcr: { cassette_name: 'google_image_search' } do
    let!(:news_items) { create_list(:uncategorized_general_news_item, 2) }

    context "upwards" do
      before do
        news_items.first.update_attributes(position: 1)
      end

      context "trending_until", vcr: { cassette_name: 'google_image_search' } do
        context "if story IS NOT appeared in the toplist before" do
          it 'trending_until changes to 6 hours' do
            news_items.last.update_attributes(:position => 2)
            expect(news_items.last.trending_until).to be_within(1.minute).of(Time.now.advance(hours: 6))
          end
        end

        context "if story was appeared in the toplist before" do
          before do
            news_items.last.update_attributes(trending_until: Time.now.advance(minutes: 5), position: 2)
          end

          it 'trending_until changes to 3 hours' do
            news_items.last.update_attributes(:position => 3)
            expect(news_items.last.trending_until).to be_within(1.minute).of(Time.now.advance(hours: 3))
          end
        end
      end
    end

    context "to position 9-18", vcr: { cassette_name: 'google_image_search' } do
      let(:news_item_with_image) { create(:uncategorized_general_news_item_with_image) }
      let(:news_item_without_image) { create(:uncategorized_general_news_item) }

      context "when news_thumbnail is set" do
        it "shouldn't set DJ search for it again" do
          expect(GeneralNewsItemWorker).not_to receive(:perform_async)
          news_item_with_image.update_attribute(:position, 10)
        end
      end

      context "when news_thumbnail is NOT set" do
        pending
      #   it "should set DJ search for it" do
      #     expect(GeneralNewsItemWorker).to receive(:perform_async)
      #     news_item_without_image.update_attribute(:position, 10)
      #   end
      end
    end
  end
end
