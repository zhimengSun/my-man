define [
  'backbone' 
  'jquery' 
  'app/views/menu.view'
  'app/models/login'
  'app/views/login.view' 
  'app/models/event'
  'app/models/user'
  'app/models/first'
  'app/collections/events'
  'app/collections/firsts'
  'app/views/events/events_view'
  'app/views/firsts/firsts_view'
  'canvas_draw'
], (Backbone, $, MenuView,  Login, LoginView, Event, User, First, Events, Firsts, EventsView, FirstsView, EnterView, CanvasDraw)->
  
  class Router extends Backbone.Router
    
    initialize: (options) ->
      window.location.href = '#login' if !@logged_in()

    swap: (newView)->  
      @currentView.leave() if @currentView && @currentView.leave
      @currentView = newView
    
    logged_in: ->
      token = window.localStorage.getItem('userAccessToken')
      if token
        App.currentUser = new User
        App.currentUser.set
          id: window.localStorage.getItem('userId')
          token: window.localStorage.getItem('userAccessToken')
          email: window.localStorage.getItem('userEmail')
      if token then true else false

    routes:
      '': 'home'
      'firsts': 'firsts'
      'login': 'login'
      
    home: ->
      $('.main').show()
      $('#page-title').show()
      menuView = new MenuView()
      $('.main').prepend(menuView.el)
      events = new Events()
      eventsView = new EventsView(collection: events)
      @swap(eventsView)
      eventsView.fetchEvents()
      $('#yield').html(eventsView.el)
    
    firsts: ->
      firsts = new Firsts()
      firstsView = new FirstsView(collection: firsts)
      @swap(firstsView)
      firstsView.fetchFirsts()
      $('#yield').html(firstsView.el)

    login: ->
      $('.main').hide()
      $('#page-title').hide()
      $('#canvas2').hide()
      login = new Login()
      loginView = new LoginView(model: login)
      @swap loginView
      $('body').prepend(loginView.el)
