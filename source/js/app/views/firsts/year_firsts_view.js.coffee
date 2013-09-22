define ['composite.view'
        'app/templates/firsts/year_firsts'
], (CompositeView)-> 

  class YearFirstsView extends CompositeView

     className: 'month-events-view'

     initialize: (options)->
       @yearFirstsTemplate = JST['app/templates/firsts/year_firsts']
       @firstsView = options.firstsView if options.firstsView
       if options.year
         @$el.html @yearFirstsTemplate(year: options.year)
         
     firsts:
       'click .month-events-view-header': 'displayMe'  

     displayMe: ->
       @firstsView.displayThisYear(@)
