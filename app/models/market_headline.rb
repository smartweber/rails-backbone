class MarketHeadline < ActiveRecord::Base
  acts_as_list add_new_at: nil
  include Trendable
  include RepositionByPlaceSwap

  after_save :reposition, if: 'self.position_changed?'
  validates :title, presence: true, length: {minimum: 10}
  validate :trending_until_is_in_future, on: [:create, :update]

  # TODO: Wrap in transaction
  def reposition
    if self.position
      unless self.trending_until_changed?
        trending_until = Time.current.advance(hours: (self.position_was.nil? ? 6 : 3))
        update_columns(trending_until: trending_until, updated_at: Time.current)
      end
      schedule_removal_from_trending
      insert_at self.position
    elsif
      update_columns(trending_until: nil, updated_at: Time.current)
    end
  end

private

  def trending_until_is_in_future
    if self.trending_until and self.trending_until <= Time.current
      errors.add(:trending_until, 'should contain future date')
    end
  end
end
