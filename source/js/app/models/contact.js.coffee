define ['backbone'], (Backbone) ->
  
  class Contact extends Backbone.Model
    
    url: ->
      App.apiHost + '/contact/' + @id + '?token=' + currentUser.get('token')
