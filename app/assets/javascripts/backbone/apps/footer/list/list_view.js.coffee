@Omega.module "FooterApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Footer extends App.Views.ItemView
    template: 'footer/list/footer'
    className: 'side-bar-footer'
