class AddNotStemmedKeywordsToFeeds < ActiveRecord::Migration
  def change
    add_column :feeds, :not_stemmed_keywords, :text
    rename_column :feeds, :keywords, :stemmed_keywords
  end
end
