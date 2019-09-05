require 'rails_helper'

describe QuoteMedia::Service, vcr: { cassette_name: 'quotemedia_quotes' }, pending: true do
  subject{ QuoteMedia::Service.new }
  let!(:parsed_response){ [{"symbolstring" => "AAPL"}, {"symbolstring" => "GOOGL"}, {"symbolstring" => "ALCO"}] }
  let!(:redis){ RedisApi.client }
  let!(:requested_symbols){ %W(AAPL GOOGL) }
  let(:time_str) { "2016-1-1 06:15:01 EST" }
  let(:zone) { ActiveSupport::TimeZone.new("Eastern Time (US & Canada)") }
  let(:permitted_time) { time_str.to_time.in_time_zone(zone) }
  let(:exchange_closed_time) { permitted_time - 2.seconds }

  before do
    # Setting time is essential since class is time-dependant
    Timecop.travel(permitted_time)
  end

  describe "initialize" do
    it "sets webmaster_id" do
      expect(subject.webmaster_id).to be(APP_CONFIG[:quote_media][:webmaster_id])
    end
    it "sets timepoint" do
      expect(subject.timepoint).to be_an_instance_of(ActiveSupport::TimeWithZone)
    end
  end

  describe ".get_quote" do
    context "during time when exchange is closed" do
      before do
        past_time_mark = subject.send(:ticks_since_timepoint, advance_in_seconds: -10)
        @outdated_quote = parsed_response[2]
        save_quote(@outdated_quote, past_time_mark)
      end
      before { @url = subject.send(:prepare_query, @outdated_quote["symbolstring"]) }
      before { Timecop.travel(exchange_closed_time) }

      it "doesn't make a needless request" do
        subject.send(:get_quote, @outdated_quote["symbolstring"])
        expect(a_request(:get, @url)).not_to have_been_made
      end

      it "returns last known request" do
        expect(subject.send(:get_quote, @outdated_quote["symbolstring"]).length).to eql(1)
      end
    end
    context "when all requested symbols can be retrieved from storage" do
      it "doesn't make a needless request" do
        url = subject.send(:prepare_query, requested_symbols)
        subject.send(:get_quote, requested_symbols)
        expect(subject.send(:get_quote, requested_symbols).length).to eql(2)
        expect(a_request(:get, url)).to have_been_made.once
      end
    end
    context "when request needs to be made and there's symbol capacity left" do
      before do
        future_time_mark = subject.send(:ticks_since_timepoint, advance_in_seconds: 10)
        soontobe_quote   = parsed_response[2]
        save_quote(soontobe_quote, future_time_mark)
      end

      its "request contains soon to be outdated symbols as well" do
        url = subject.send(:prepare_query, %W(AAPL ALCO))
        subject.send(:get_quote, %W(AAPL ALCO))
        expect(a_request(:get, url)).to have_been_made.once
      end
    end
    context "when some of the requested symbols are" do
      context "outdated" do
        before do
          past_time_mark   = subject.send(:ticks_since_timepoint, advance_in_seconds: -10)
          future_time_mark = subject.send(:ticks_since_timepoint, advance_in_seconds: 10)
          outdated_quote   = parsed_response[0]
          uptodate_quote   = parsed_response[1]
          soontobe_quote   = parsed_response[2]
          save_quote(outdated_quote, past_time_mark)
          save_quote(uptodate_quote, future_time_mark)
          save_quote(soontobe_quote, past_time_mark)
        end

        its "request contains both not request-specified outdated symbols, soon-to-outdate and requested outdated symbol" do
          url = subject.send(:prepare_query, %W(AAPL ALCO GOOGL))
          subject.send(:get_quote, requested_symbols)
          expect(a_request(:get, url)).to have_been_made.once
        end
      end
      context "not previously saved locally" do
        before do
          future_time_mark = subject.send(:ticks_since_timepoint, advance_in_seconds: 10)
          uptodate_quote   = parsed_response[1]
          save_quote(uptodate_quote, future_time_mark)
        end

        its "request contains not saved symbol and soon-to-outdate symbol" do
          url = subject.send(:prepare_query, %W(AAPL GOOGL))
          subject.send(:get_quote, requested_symbols)
          expect(a_request(:get, url)).to have_been_made.once
        end
      end
      context "saved but with broken integrity" do
        before do
          future_time_mark = subject.send(:ticks_since_timepoint, advance_in_seconds: 10)
          uptodate_quote   = parsed_response[0]
          save_quote(uptodate_quote, future_time_mark)
          RedisApi.client.sadd(described_class::QUOTES_LISTING_KEY, 'ALCO')
        end

        its "request contains those symbols and soon-to-outdate symbol" do
          url = subject.send(:prepare_query, %W(ALCO AAPL))
          subject.send(:get_quote, %W(AAPL ALCO))
          expect(a_request(:get, url)).to have_been_made.once
        end
      end
    end
  end

  describe ".exchange_active_now?" do
    let(:saturday) { "2016-1-2 06:15:01 EST".to_time.in_time_zone(zone) }
    let(:sunday) { "2016-1-3 20:14:59 EST".to_time.in_time_zone(zone) }

    context "when day is the saturday" do
      before { Timecop.travel(saturday) }
      it { expect(subject.send(:exchange_active_now?)).to eql(false) }
    end
    context "when day is the sunday" do
      before { Timecop.travel(sunday) }
      it { expect(subject.send(:exchange_active_now?)).to eql(false) }
    end
    context "when requesting during time exchange is closed at" do
      before { Timecop.travel(exchange_closed_time) }
      it { expect(subject.send(:exchange_active_now?)).to eql(false) }
    end
    context "when requesting during permitted range" do
      before { Timecop.travel(permitted_time) }
      it { expect(subject.send(:exchange_active_now?)).to eql(true) }
    end
  end

  describe ".not_saved_symbols" do
    before do
      expect_any_instance_of(Redis).to receive(:smembers).and_return(%W(AAPL AA))
    end

    it "returns not saved locally symbols" do
      expect(subject.send(:not_saved_symbols, %W(AAPL GOOGL AA))).to eq(%W(GOOGL))
    end
  end

  describe ".prepare_query" do
    it "returns prepared url" do
      expect(subject.send(:prepare_query, requested_symbols)).to eq("http://app.quotemedia.com/data/getQuotes.json?symbols=AAPL,GOOGL&webmasterId=102098")
    end
  end

  describe ".exclude_not_relevant" do
    let(:quotes){ subject.send(:retrieve_quotes, requested_symbols) }
    let(:quotes_with_unrelated_data){ quotes.push({"symbolstring" => "OTHR"}) }

    it "returns filtered set of quotes" do
      expect(subject.send(:exclude_not_relevant, requested_symbols, quotes_with_unrelated_data).length).to eq(2)
    end
  end

  describe ".retrieve_quotes" do
    it "returns array of saved quotes" do
      expect(subject.send(:retrieve_quotes, requested_symbols).length).to eq(2)
    end
  end

  describe ".soon_to_be_outdated_quotes" do
    it "returns quotes that need to be refreshed" do
      expect_any_instance_of(Redis).to receive(:zrangebyscore).and_return(parsed_response.map(&:to_json))
      expect(subject.send(:soon_to_be_outdated_quotes, %W(ALCO GOOGL AA), %W(ALCO GOOGL), Time.now.to_f)).to eq(%W(AAPL))
    end

    it "doesn't exceed the possible amount" do

    end
  end

  describe ".outdated_symbols_amongst" do
    before do
      expect_any_instance_of(Redis).to receive(:zrangebyscore).and_return(parsed_response.map(&:to_json))
    end

    it "returns outdated symbols of quotes stored locally" do
      expect(subject.send(:outdated_symbols_amongst, %W(AAPL ACO), Time.now.to_f)).to eql(%W(AAPL))
    end
  end

  describe ".parse" do
    let(:response){ {'results' => {'quote' => [{'foo' => 'bar'}]}} }

    it "returns parsed response" do
      expect(subject.send(:parse, response.to_json)).to eq(response['results']['quote'])
    end
  end

  describe ".save_quotes" do
    let(:quotes){ subject.send(:retrieve_quotes, requested_symbols) }

    it "saves quotes to appropriate places" do
      expect{ subject.send(:save_quotes, quotes) }.to begin
        change{ redis.zrange(described_class::SORTED_QUEUE_KEY, 0, -1).length }.by(2) and
        change{ redis.smembers(described_class::QUOTES_LISTING_KEY) }.by(requested_symbols)
      end
      expect{ redis.get(described_class::QUOTE_TIMESTAMP_KEY_PREFIX + requested_symbols[0]).to_f }.not_to raise_error
    end

    it "saves quotes wrapping calls to redis into transaction" do
      expect_any_instance_of(Redis).to receive(:multi).twice
      subject.send(:save_quotes, quotes)
    end
  end
end

def save_quote(json_quote, deprecation_time)
  RedisApi.client.multi do
    RedisApi.client.zadd(described_class::SORTED_QUEUE_KEY, deprecation_time, json_quote.to_json)
    RedisApi.client.sadd(described_class::QUOTES_LISTING_KEY, json_quote["symbolstring"])
    RedisApi.client.set(subject.send(:full_key_address_for, json_quote["symbolstring"]), deprecation_time)
  end
end
