define ['backbone', 'app/models/event'], (Backbone, Event)->
  
  class Events extends Backbone.Collection
    
    initialize: (models, options)->
      date = new Date()
      @prevDate = date.getFullYear() + '-' + (date.getMonth() + 1) + '-01'
      @nextDate = date.getFullYear() + '-' + (date.getMonth() + 1) + '-31'

    model: Event

    url: ->
      token = if App.currentUser then App.currentUser.get('token') else ''
      App.apiHost + '/events?get_json=true&token=' + token
