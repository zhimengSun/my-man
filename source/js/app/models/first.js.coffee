define ['backbone'], (Backbone) ->
  
  class First extends Backbone.Model
    
    url: ->
      App.apiHost + '/first/' + @id + '?token=' + currentUser.get('token')
