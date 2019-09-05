# REFACTOR
class CompanyWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  def expiration
    @expiration ||= 60*60*7 # store job details for 7 hours max
  end

  def perform(method, *args)
    CompanyWorker.send("#{method}", *args)
  end

  def self.remove_from_trending(company_id)
    company = Company.find(company_id)
    if company.position and company.position.between?(1, 5)
      company.replace_with_default
    else
      company.remove_from_list
    end
  end
end
