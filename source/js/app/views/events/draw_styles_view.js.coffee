define ['jquery'
        'backbone'
        'underscore'
        'canvas_draw'
        'app/views/events/enter_view'
        'app/templates/events/draw_styles'
        ], ($, Backbone, _, CanvasDraw, EnterView, DrawStyleTemplate) ->
  
  window.isEraser = false

  class DrawStylesView extends Backbone.View
    
    initialize: (options) ->
      @currentSize = @$el.find('.draw-size-1')

    template: JST["app/templates/events/draw_styles"]

    el: '#draw_style'

    events:
      'click #eraser' : 'eraser'

    eraser: ->
      window.isEraser = true
    
    render: ->
      
      @$el.html @template

      $("#draw_style").find('.color').each (i) -> 
        color = $(@).html()
        $(@).css
          background: color
          border: '2px ' + color + ' solid'
    
      $("#draw_style").find('.size').each (i) ->
        s = $(@).html()
        $(@).addClass("draw-size-" + s)
      
      view = this

      @currentColor = $ @$el.find('.color')[0]

      $("#draw_style").find('div').each (i) ->
        $(@).click ->
          style = $(@).attr 'class'
          if style.match 'size'
            drawStyles = 
              size: $(@).width()
            if view.currentSize
              view.currentSize.css
                border: 'none'
              view.currentSize = $(@)
              view.currentSize.css
                border: '2px #fff solid'
          if style is 'color'
            color = $(@).html()
            drawStyles = 
              color: color
            if view.currentColor
              view.currentColor.css
                border: '2px ' + view.currentColor.html() + ' solid'
              view.currentColor = $(@)
              view.currentColor.css
                border: '2px #fff solid'

          canvas_draw.drawStyle drawStyles
      @




