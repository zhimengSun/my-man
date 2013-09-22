define ['composite.view' 
        'jquery'
        'app/views/events/event_view'
        'app/views/events/month_events_view'
        'app/templates/events/index'
], (CompositeView, $, EventView, MonthEventsView)->

  class EventsView extends CompositeView
    
    id: 'events-view' 
    
    initialize: (options) ->
      @indexTemplate = JST['app/templates/events/index']
      @$el.html @indexTemplate
      @listenTo(@collection, 'add', @addEvent)
    
    events:
      "click #events-view-more": "fetchEvents"
  
    fetchEvents: ->
      prevDate = @collection.prevDate
      nextDate = @collection.nextDate
      @collection.eventsNum = 0

      monthData = prevDate

      monthEventsView = new MonthEventsView
        eventsView: @
        month: monthData
      @$el.html monthEventsView.el
      
      @currentMonth = monthEventsView
      $('#loading').show()
      @collection.fetch
        wait: true
        remove: false
        data:
          start_date: prevDate
          end_date: nextDate
        success: =>
          @displayThisMonth(@currentMonth)
          $('#loading').hide()
    addEvent: (event) ->
      eventView = new EventView(model: event)
      @appendChildTo(eventView, $('.events-content'))

    displayThisMonth: (month) ->
      @thisMonth.$el.find('ul').hide() if @thisMonth
      @thisMonth = month
      @thisMonth.$el.find('ul').show()
