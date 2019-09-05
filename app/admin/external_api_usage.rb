ActiveAdmin.register_page "External API Usage" do
  content do
    table do
      thead do
        tr do
          th "QuoteMedia(requests/month)*"
        end
      end
      tbody do
        tr do
          td RedisApi.client.get(QuoteMedia::Service::API_REQUESTS_USED_KEY)
        end
      end
    end

    para "* This doesn't include any possible requests made from other hosts."
  end
end
