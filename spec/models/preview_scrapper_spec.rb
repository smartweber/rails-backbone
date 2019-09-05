require 'rails_helper'

RSpec.describe PreviewScrapper, type: :model do
  before { @link = 'http://localhost/logo.jpeg'}

  describe "new" do
    it do
      ps = PreviewScrapper.new(@link)
      expect(ps.link).to eq @link
      expect(ps.is_image).to eq true
    end
  end

  describe "run" do
    pending
  end

  describe "image_url_provided?" do
    it do
      ps = PreviewScrapper.new(@link)
      expect(ps.image_url_provided?).to eq true
    end
  end
end