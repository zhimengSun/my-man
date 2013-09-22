define ['composite.view'
        'app/templates/events/month_events'
], (CompositeView)-> 

  class MonthEventsView extends CompositeView

     className: 'month-events-view'

     initialize: (options)->
       @monthEventsTemplate = JST['app/templates/events/month_events']
       @eventsView = options.eventsView if options.eventsView
       if options.month
         @$el.html @monthEventsTemplate(month: options.month)
         
     events:
       'click .month-events-view-header': 'displayMe'  

     displayMe: ->
       @eventsView.displayThisMonth(@)
