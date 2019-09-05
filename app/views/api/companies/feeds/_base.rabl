object @feed

attribute :posts_count

child @feed.posts => :posts do
  extends('api/posts/_extended')
end
