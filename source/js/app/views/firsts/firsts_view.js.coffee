define ['composite.view' 
        'jquery'
        'app/views/firsts/first_view'
        'app/views/firsts/year_firsts_view'
        'app/templates/firsts/index'
], (CompositeView, $, FirstView, YearFirstsView)->

  class FirstsView extends CompositeView
    
    id: 'events-view'
    
    initialize: (options) ->
      @indexTemplate = JST['app/templates/firsts/index']
      @$el.html @indexTemplate
      @listenTo(@collection, 'add', @addFirst)
    
    fetchFirsts: ->
      year = @collection.year
      yearFirstsView = new YearFirstsView
        firstsView: @
        year: year
      @$el.html yearFirstsView.el
      
      @currentYear = yearFirstsView
      $('#loading').show()
      @collection.fetch
        wait: true
        remove: false
        data:
          year: year
        success: =>
          @displayThisYear(@currentYear)
          $('#loading').hide()
      
    addFirst: (first) ->
      firstView = new FirstView(model: first)
      @appendChildTo(firstView, $('.events-content'))

    displayThisYear: (year) ->
      @thisYear.$el.find('ul').hide() if @thisYear
      @thisYear = year
      @thisYear.$el.find('ul').show()
