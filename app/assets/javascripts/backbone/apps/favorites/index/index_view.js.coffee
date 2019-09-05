@Omega.module "FavoritesApp.Index", (Index, App, Backbone, Marionette, $, _) ->

  class Index.Layout extends App.Views.Layout
    template: 'favorites/index/layout'

    regions:
      userRegion:  '#user-region'
      feedRegion:  '#feed-region'
      modalRegion: '#modal-region'

  class Index.UserInfo extends App.Views.ItemView
    template: 'favorites/index/_user_info'

  class Index.Modal extends App.Views.ItemView
    template: 'favorites/index/_modal'
