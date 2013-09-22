define [
  'composite.view',
  'jquery',
  'app/views/profile.view',
  'app/templates/menus/menu',
  'app/templates/menus/logged_menu',
], (CompositeView, $, ProfileView) ->
  
  class MenuView extends CompositeView 
    
    tagName: 'nav'
    id: 'menu-view' 

    initialize: (options) ->
      menuTemplate = JST['app/templates/menus/menu'] 
      @loggedMenuHtml = JST['app/templates/menus/logged_menu']
      @$el.html(menuTemplate)
      @appendProfileMenu()
      @clickedMenu = @$el.find('#events')

    appendProfileMenu: ->
      @profileView = new ProfileView
        userData:
          name: '孙志萌'
          email:App.currentUser.get('email')
      @$el.find('ul').append @loggedMenuHtml
      $('body').append @profileView.el

    events:
      'click #events': 'navFutureEvents'
      'click #firsts': 'navFirsts'
      'click #profile': 'userProfile'
 
    navFutureEvents: ->
      @toggleClickedMenu @$el.find('#events')
      window.App.router.navigate '#',
        trigger: true

    navFirsts: ->
      @toggleClickedMenu @$el.find('#firsts')
      window.App.router.navigate '#firsts',
        trigger: true
    
    userProfile: ->
      clickedImage = @$el.find('.profile-icon')
      imgUrl = clickedImage.css('background-image').replace('close', 'open')
      clickedImage.css('background-image', imgUrl)
      @profileView.openDialog()
      
    navLogin: ->
      window.App.router.navigate '#login',
        trigger: true
    
    toggleClickedMenu: (clickedMenu)->
      if @clickedMenu
        clickedImage = @clickedMenu.find('span')
        imgUrl = clickedImage.css('background-image').replace('open', 'close')
        clickedImage.css('background-image', imgUrl)
        @clickedMenu.css('color', "rgb(124, 124, 124)")

        @clickedMenu = clickedMenu
        clickedImage = @clickedMenu.find('span')
        imgUrl = clickedImage.css('background-image').replace('close', 'open')
        clickedImage.css('background-image', imgUrl)
        @clickedMenu.css('color', "#ffffff")
