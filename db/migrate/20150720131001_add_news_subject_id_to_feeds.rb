class AddNewsSubjectIdToFeeds < ActiveRecord::Migration
  def change
    add_column :feeds, :news_subject_id, :integer
  end
end
