require 'rails_helper'

RSpec.describe UserAttachment, :type => :model do
  subject{ UserAttachment }

  describe "link=" do
    before do
      @scrapper = stubbed_scrapper
      expect(PreviewScrapper).to receive(:new).with(@scrapper.link).and_return(@scrapper)
    end

    it "sets all attributes correctly" do
      a = subject.new
      a.link = @scrapper.link
      expect(a.title).to eq @scrapper.title
      expect(a.remote_image_url).to eq @scrapper.image_url
      expect(a.link).to eq @scrapper.link
      expect(a.description).to eq @scrapper.description
      expect(a.type_of_attachment).to eq 'link'
    end
  end
end
