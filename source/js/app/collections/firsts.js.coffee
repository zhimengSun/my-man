define ['backbone', 'app/models/first'], (Backbone, First)->
  
  class Firsts extends Backbone.Collection
    
    initialize: (models, options)->
      date = new Date()
      @year = date.getFullYear()

    model: First

    url: ->
      token = if App.currentUser then App.currentUser.get('token') else ''
      App.apiHost + '/firsts?get_json=true&token=' + token
