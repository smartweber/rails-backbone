module Trendable
  extend ActiveSupport::Concern

  included do
    def schedule_removal_from_trending
      if self.position
        old_job_id = RedisApi.client.get("#{self.class.to_s.downcase}:#{self.id}:removal_from_trending:job_id")
        new_job_id = "#{self.class.to_s}Worker".constantize.perform_at(self.trending_until, 'remove_from_trending', self.id)
        RedisApi.client.set("#{self.class.to_s.downcase}:#{self.id}:removal_from_trending:job_id", new_job_id)
        Sidekiq::Status::unschedule(old_job_id) if old_job_id
      end
    end
  end
end
