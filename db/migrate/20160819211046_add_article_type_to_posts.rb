class AddArticleTypeToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :article_type, :string

    reversible do |dir|
      dir.up do
        Post.where.not(article_id: nil).find_each(batch_size: 250) do |r|
          r.update_attribute(:article_type, "Article")
        end
      end
    end
  end
end
