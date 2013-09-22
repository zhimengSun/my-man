define ['composite.view', 
        'app/templates/menus/profile'
], (CompositeView)->

  class ProfileView extends CompositeView

    tagName: 'section' 
    className: 'profile-view' 

    initialize: (options)->
      @profileHtml = JST['app/templates/menus/profile']
      @$el.html @profileHtml(options.userData) if options.userData

    events:
      'click #menu-view-logout': 'logout'
      'click .profile-view-close': 'closeDialog'
      'click .profile-view-modal': 'closeDialog'

    logout: ->
      window.localStorage.removeItem('userAccessToken')
      window.localStorage.removeItem('userEmail')
      window.localStorage.removeItem('userId')
      @closeDialog()
      console.info 'logout'
      window.location.href = '#login'
    
    openDialog: ->
      @$el.find('.profile-view-modal').show()
      @$el.find('.profile-view-dialog').show().animate
        width: '80%',
        'fast'

    closeDialog: ->
      @$el.find('.profile-view-modal').hide()
      dialog = @$el.find('.profile-view-dialog')
      dialog.animate
        width: '0%',
        'fast',
        ->
         dialog.hide()

      clickedImage = $('.profile-icon')
      imgUrl = clickedImage.css('background-image').replace('open', 'close')
      clickedImage.css('background-image', imgUrl)
