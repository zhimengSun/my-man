define ['backbone', 'app/models/contact'], (Backbone, Contact)->
  
  class Contacts extends Backbone.Collection
    
    model: Contact
