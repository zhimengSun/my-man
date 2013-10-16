define ['composite.view' 
        'jquery'
        'app/views/contacts/contact_view'
        'app/templates/contacts/index'
], (CompositeView, $, ContactView)->

  class ContactsView extends CompositeView
    
    id: 'events-view'
    
    initialize: (options) ->
      @contacts = navigator.contacts
      @indexTemplate = JST['app/templates/contacts/index']
      @$el.html @indexTemplate
      @listenTo(@collection, 'add', @addContact)
    
    addContact: (contact) ->
      contactView = new ContactView(model: contact)
      @appendChildTo(contactView, $('.events-content'))
