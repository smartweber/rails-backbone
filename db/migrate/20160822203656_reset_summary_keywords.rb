class ResetSummaryKeywords < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        GeneralNewsItem.where('created_at > ?', 3.days.ago).find_each(batch_size: 250) do |r|
          r.summary = r.summary
          r.set_keywords!
          r.save
        end
      end
    end
  end
end
