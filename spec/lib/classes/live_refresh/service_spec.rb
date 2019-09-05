require 'rails_helper'

describe LiveRefresh::Service do
  subject { LiveRefresh::Service.new }
  let(:urls) { Rails.application.routes.url_helpers }
  let(:ns) { Rails.configuration.redis.faye.namespace }

  describe ".initialize" do
    it "connects to redis" do
      EM.run do
        expect(subject.instance_variable_get(:@redis)).to be_kind_of(EM::Hiredis::Client)
        EM.stop
      end
    end
  end

  describe ".add_timers" do
    it "add periodic timer" do
      expect(EM).to receive(:add_periodic_timer).twice
      EM.run do
        subject
        EM.stop
      end
    end
  end

  describe ".add_listeners" do
    let(:channel) { urls.api_subscriptions_company_path('AAPL') }

    it "subscribes upon redis channel" do
      expect_any_instance_of(EventMachine::Hiredis::PubsubClient).to receive(:psubscribe).with(ns + urls.api_subscriptions_company_path(id: '*'))
      EM.run do
        subject
        EM.stop
      end
    end

    it "perform forwarding of received through Redis pub/sub message to Faye channels" do
      # expect_any_instance_of(LiveRefresh::Service).to receive(:publish).with(channel, message: true)
      # EM.run do
      #   subject
      #   redis = subject.instance_variable_get(:@redis)
      #   redis.publish(ns + channel, message: true).callback { |n|
      #     EM.stop
      #   }
      # end
    end
  end

  describe ".extract_abbr_from" do
    let(:url){ urls.api_subscriptions_company_path('AAPL') }

    it do
      expect(LiveRefresh.extract_abbr_from(url)).to eql('AAPL')
    end
  end

  describe ".refresh_companies_with_viewers" do
    before do
      @companies_with_viewers = %W(AAPL GOOGL)
      client_ids = %W(123weqwe s432rewe)
      @companies_with_viewers.each_with_index do |abbr, i|
        RedisApi.client.sadd("#{ns}/channels/api/subscriptions/c/#{abbr}", client_ids[i])
      end
    end

    it "invokes getQuote QM interface" do
      # TODO: figure out why .reverse is needed
      expect(QuoteMedia.client).to receive(:get_quote).with(@companies_with_viewers)
      EM.run do
        subject.send(:refresh_companies_with_viewers)
        EM.stop
      end
    end
  end

  describe ".publish" do
    pending
  end
end
