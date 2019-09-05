require 'open-uri'

namespace :companies do
  desc "Fetch and save exchange companies info from url"
  task :add, [:exgroup] => :environment do |t, args|
    args.with_defaults(exgroup: 'nsd')
    begin
      response = open("http://app.quotemedia.com/data/getFundamentalsByExchange.json?webmasterId=102098&exgroup=#{args[:exgroup]}")
    rescue
      puts "Error while fetching json list from url"
    end
    json = JSON.parse(File.read(response))
    puts "No data returned in the response. Probably wrong exgroup?" if json['results']['symbolcount'] == 0
    saved_counter = with_errors_counter = 0
    json['results']['company'].each do |obj|
      unless obj['fundamental'].blank? or obj['fundamental']['marketcap'].blank? or obj['fundamental']['marketcap'] < 500000000
        name       = obj['symbolinfo']['equityinfo']['longname']
        abbr       = obj['symbolinfo']['equityinfo']['shortname']
        exchange   = obj['symbolinfo']['key']['exchange']
        market_cap = obj['fundamental']['marketcap']
        company = Company.create(name: name, abbr: abbr, market_cap: market_cap, exchange: exchange)
        if company.persisted?
          saved_counter += 1
          print '.'
        else
          print '-'
          with_errors_counter += 1
        end
      end
    end
    puts "\nSaved: #{saved_counter}. Not saved due to validation errors: #{with_errors_counter}"
  end

  desc "Import companies from CSV files"
  task :import, [:exgroup] => :environment do
    csv_files = File.join(Rails.root, "lib", "files", "companies", "*.csv")
    Dir.glob(csv_files).each do |file|
      puts "Importing companies from #{File.basename(file)}"
      CSV.foreach(file, :headers => true) do |row|
        Company.create(name: row["Company Name"], abbr: row["Ticker"], exchange: row["Exchange"], market_cap: row["Market Cap"], sector: row["Sector"])
      end
    end
  end
end
