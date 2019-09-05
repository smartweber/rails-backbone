@Omega.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.Feed extends App.Entities.Model
    defaults:
      unseen_posts: 0

    initialize: ->
      @set(posts: new Entities.PostCollection)

    parse: (response) ->
      response.posts = new Entities.PostCollection response.posts
      response

    updateWith: (message) ->
      switch message.message_type
        when 'post_count_update'
          if @get('posts').where({id: message.latest_post_id}).length == 0
            unseen_posts = message.new_value - @get('posts_count')
            @set(unseen_posts: unseen_posts)
        when 'comment_count_update'
          @get('posts').at(message.target_object_id).comments_count = message.new_value

    addNewPosts: ->
      posts     = new Entities.PostCollection
      posts.url = @url
      posts.fetch { data: { latest_post_id: @get('posts').at(0).get('id') }, success: (collection) =>
        @get('posts').add(collection.models, {at: 0})
      }
      @clearUnseenPostsDifference()

    clearUnseenPostsDifference: ->
      newValue = @get('posts_count') + @get('unseen_posts')
      @set(posts_count: newValue, unseen_posts: 0)

  API =
    newFeed: (attributes) ->
      new Entities.Feed attributes

    getFeedByURL: (path, page) ->
      feed     = @newFeed()
      feed.url = path
      feed.fetch { data: { page: page } }
      feed

  App.reqres.setHandler "feed:entity", (attributes) ->
    API.newFeed(attributes)

  App.reqres.setHandler "article:show:feed", (page=1, articleId) ->
    API.getFeedByURL( Routes.feed_api_article_path(articleId), page )

  App.reqres.setHandler "general_news_item:show:feed", (page=1, newsArticleId) ->
    API.getFeedByURL( Routes.feed_api_news_article_path(newsArticleId), page )

  App.reqres.setHandler "user:show:feed", (page=1, userId) ->
    API.getFeedByURL( Routes.api_user_posts_path(userId), page )

  App.reqres.setHandler "feed:show:feed", (page=1) ->
    API.getFeedByURL( Routes.api_feed_index_path(), page )

  App.reqres.setHandler "user:favorite:feed", (page=1) ->
    API.getFeedByURL( Routes.api_favorites_path(), page )

  App.reqres.setHandler "company:show:feed", (page=1, abbr) ->
    API.getFeedByURL( Routes.api_company_posts_path(abbr), page )

  App.reqres.setHandler "trending:stock:feed", (page=1) ->
    API.getFeedByURL( Routes.trending_api_posts_path(), page )

  App.reqres.setHandler "channel:show:feed", (page=1, channelName) ->
    API.getFeedByURL( Routes.api_channel_path(channelName), page )
