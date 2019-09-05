require 'rails_helper'

describe LiveRefresh do
  let(:urls) { Rails.application.routes.url_helpers }

  describe "#extract_abbr_from" do
    let(:url){ urls.api_subscriptions_company_path('AAPL') }

    it do
      expect(subject.extract_abbr_from(url)).to eql('AAPL')
    end
  end

  describe "#start" do
    pending
  end
end
