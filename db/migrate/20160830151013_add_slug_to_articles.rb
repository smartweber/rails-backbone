class AddSlugToArticles < ActiveRecord::Migration
  def change
    add_column :articles, :slug, :string
    add_index :articles, :slug, unique: true

    reversible do |dir|
      dir.up do
        Article.find_each(batch_size: 250).each do |r|
          begin
            r.save!
          rescue ActiveRecord::RecordInvalid
          end
        end
      end
    end
  end
end
