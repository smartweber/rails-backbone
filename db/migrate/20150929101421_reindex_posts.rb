class ReindexPosts < ActiveRecord::Migration
  def up
    WebMock.allow_net_connect! if defined?(WebMock)
    Post.reindex
  end
end
