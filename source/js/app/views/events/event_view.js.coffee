define ['composite.view' 
        'jquery' 
        'underscore'
        'app/templates/events/event'
], (CompositeView, $, _, EventTemplate)->

  class EventView extends CompositeView
    
    className: 'event-view'

    initialize: (options)->
      @eventTemplate = JST['app/templates/events/event']
        
    render: ->
      @$el.html @eventTemplate
        event: @model
      @

  