define ['composite.view' 
        'jquery' 
        'underscore'
        'app/templates/contacts/contact'
], (CompositeView, $, _, ContactTemplate)->

  class ContactView extends CompositeView
    
    className: 'event-view'

    template: JST['app/templates/contacts/contact']
        
    render: ->
      @$el.html @template
        contact: @model
      @

  
