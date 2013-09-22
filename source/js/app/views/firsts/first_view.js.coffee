define ['composite.view' 
        'jquery' 
        'underscore'
        'app/templates/firsts/first'
], (CompositeView, $, _, FirstTemplate)->

  class FirstView extends CompositeView
    
    className: 'event-view'

    template: JST['app/templates/firsts/first']
        
    render: ->
      @$el.html @template
        first: @model
      @

  