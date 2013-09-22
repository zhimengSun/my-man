define ['backbone'], (Backbone)->
  
  class Login extends Backbone.Model 
  
    urlRoot: window.App.apiHost + '/login'
