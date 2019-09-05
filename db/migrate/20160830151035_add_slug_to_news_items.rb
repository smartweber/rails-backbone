class AddSlugToNewsItems < ActiveRecord::Migration
  def change
    add_column :news_items, :slug, :string
    add_index :news_items, :slug, unique: true

    reversible do |dir|
      dir.up do
        GeneralNewsItem.find_each(batch_size: 250).each do |r|
          begin
            r.save!
          rescue ActiveRecord::RecordInvalid
          end
        end
      end
    end
  end
end
