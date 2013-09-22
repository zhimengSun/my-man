define ['underscore', 'jquery', 'backbone'], (_, $, Backbone)->
  
  class CompositeView extends Backbone.View
    
    constructor: ->
      this.children = _([])
      this.bindings = _([])
      super

    leave: -> 
      this.off()
      this.unbindFromAll()
      this.remove()
      this._leaveChildren()
      this._removeFromParent()
    
    bindTo: (source, event, callback)-> 
      source.on(event, callback, this)
      this.bindings.push({ source: source, event: event, callback: callback })

    unbindFromAll: -> 
      this.bindings.each( (binding)->
        binding.source.off(binding.event, binding.callback)
      )
      this.bindings = _([])

    renderChild: (view)-> 
      view.render()
      this.children.push(view)
      view.parent = this
    
    renderChildInto: (view, container)-> 
      this.renderChild(view)
      this.$(container).html(view.el)

    appendChild: (view)-> 
      this.renderChild(view)
      this.$el.append(view.el)
    
    appendChildTo: (view, container)-> 
      this.renderChild(view)
      this.$(container).append(view.el)
    
    prependChild: (view)-> 
      this.renderChild(view)
      this.$el.prepend(view.el)
    
    prependChildTo: (view, container)-> 
      this.renderChild(view)
      this.$(container).prepend(view.el)

    _leaveChildren: -> 
      this.children.chain().clone().each (view)-> 
        view.leave() if view.leave

    _removeFromParent: -> 
      this.parent._removeChild(this) if this.parent

    _removeChild: (view)-> 
      index = this.children.indexOf(view)
      this.children.splice(index, 1)

