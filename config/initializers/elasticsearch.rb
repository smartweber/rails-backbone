Searchkick.client = Elasticsearch::Client.new(hosts: [APP_CONFIG[:elasticsearch][:host]+':'+APP_CONFIG[:elasticsearch][:port]], retry_on_failure: true)
