define ['backbone', 'app/models/user'], (Backbone, User)->
  
  class Users extends Backbone.Collection
    
    model: (attrs, options) ->
      new User attrs,
        parse: true
    
    urlWithToken: (baseUrl) ->
      baseUrl + "?token=" + currentUser.get('token')

    getPresenters: ->
      jqxhr = $.getJSON(currentMeeting.getOnlineUserUrl() + '?token=' + currentUser.get('token'))
      .success (data, status, xhr) =>
        @reset data.data
        has_user = _.include(presenters_view.collection.models, currentUser)
        if !has_user && !isHost
          presenters_view.collection.add currentUser 
        @trigger("getOnlineUsers")
