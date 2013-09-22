define ['backbone'], (Backbone)->
  
  class Register extends Backbone.Model 
  
    urlRoot: window.App.apiHost + '/sign'
