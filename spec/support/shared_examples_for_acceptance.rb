RSpec.shared_examples "feed" do |description, predefined_posts|
  let!(:posts) do
    return predefined_posts if predefined_posts
    posts = Post.last(2)
    if posts.size == 0
      article_id ||= Article.last.try(:id)
      article_type = 'Article' if article_id
      posts = create_list(:post, 2, article_id: article_id, article_type: article_type)
    end
    posts
  end
  let(:post_excluded_attributes) { %w(content user_id picture friends_only marked_for_deletion article_id article_type updated_at) }
  let(:first_post_user) { posts.first.user}
  let(:user_attributes) { first_post_user.attributes.extract!(*%w(id name username)) }

  response_field :posts_count, 'Total post count in article Feed'
  response_field 'posts[][id]', 'Post id'
  response_field 'posts[][created_at]', 'DateTime post was created at'
  response_field 'posts[][comments_count]', 'Amount of comments for a post'
  response_field 'posts[][content]', 'Post content(with $/@/# wrapped into links)'
  response_field 'posts[][favorited]', 'Favorite entity id(delete to unfavorite)'
  response_field 'posts[][likes_count]', 'Cached amount of likes'
  response_field 'posts[][article_id]', 'ID of article object that this post belongs to'
  response_field 'posts[][article_type]', 'Type of article object("Article"/"GeneralNewsItem") that this post belongs to'
  response_field 'posts[][like]', 'DEPRECATED'
  response_field 'posts[][user][id]', 'Id of user that\'s created post'
  response_field 'posts[][user][name]', 'Name of the creator'
  response_field 'posts[][user][gravatar_url]', 'Url for gravatar image'
  response_field 'posts[][comments][]', 'See POST /comments for a description'
  response_field 'posts[][attachments][][id]', 'Attachment ID'
  response_field 'posts[][attachments][][url]', 'URL of attached image'

  example_request description do
    expect(status).to eq(200)
    expect( json['posts_count'] ).to be_eql( posts.size )
    expect( json['posts'].first.except!(*post_excluded_attributes) ).to be_eql(
      convert_times(posts.first.reload.attributes).except!(*post_excluded_attributes)
        .merge!(
          'user' => user_attributes.merge!('gravatar_url' => gravatar_url_for(first_post_user, size: 50)),
          'attachments' => [],
          'comments' => [],
          'like' => nil,
          'favorited' => false
        )
    )
  end
end
