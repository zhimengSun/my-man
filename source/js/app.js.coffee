require ['jquery', 
         'backbone',
         'router'
        ],
($, Backbone, Router) ->

  $(document).ready ->
    FastClick.attach(document.body)
    window.App.router = new Router()
    Backbone.history.start() 
      
       
    
