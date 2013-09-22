define ['backbone'], (Backbone) ->
  
  class Event extends Backbone.Model
    
    url: ->
      App.apiHost + '/events/' + @id + '?token=' + currentUser.get('token')
