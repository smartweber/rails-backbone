class BreakingNews < ActiveRecord::Base
  validates_presence_of :title
  validates_presence_of :trending_until, on: :create

  after_save :change_status, if: :published_and_changed?
  after_destroy :publish_delete_message, if: 'self.trending_until'
  after_commit :unschedule_removal, on: :destroy

  scope :enabled, ->{ where.not(trending_until: nil) }

  def change_status
    if self.trending_until
      self.enable!
    else
      self.disable!
    end
  end

  def published_and_changed?
    self.trending_until_changed? or (self.trending_until and self.title_changed?)
  end

  def enable!
    BreakingNews.disable_all!(self.id)
    self.schedule_removal
    self.publish_update_message
  end

  def disable!
    self.update_column(:trending_until, nil) if self.trending_until
    self.unschedule_removal
  end

  def publish_delete_message
    self.unschedule_removal
    BreakingNews.publish( { id: self.id, deleted: true } )
  end

  def self.disable_all!(exception_id = nil)
    BreakingNews.where.not(id: exception_id).enabled.each(&:disable!)
  end

  def schedule_removal
    job_id = BreakingNewsWorker.perform_at(self.trending_until, 'remove_from_trending', self.id)
    RedisApi.client.set("breaking_news:#{self.id}:removal_from_trending:job_id", job_id)
  end

  def unschedule_removal
    old_job_id = RedisApi.client.get("breaking_news:#{self.id}:removal_from_trending:job_id")
    Sidekiq::Status::unschedule(old_job_id) if old_job_id
  end

  def publish_update_message
    message = RablHelper.render('api/breaking_news/_base', self)
    BreakingNews.publish( message )
  end

  def self.publish( message )
    Bayeux.client.publish( Rails.application.routes.url_helpers.api_subscriptions_breaking_news_path, message )
  end
end
