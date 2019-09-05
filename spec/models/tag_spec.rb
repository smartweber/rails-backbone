require "rails_helper"

describe Tag, type: :model do

  context "callbacks" do
    describe ".nullify_taggings_counter" do
      let!(:hashtag) { create(:hashtag, taggings_count: 2) }

      it "taggings_count resets on mute_until change" do
        hashtag.update_attribute(:mute_until, 1.day.since)
        expect(hashtag.reload.taggings_count).to be_eql 0
      end
    end
  end
end
