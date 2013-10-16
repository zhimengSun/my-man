define [
  'composite.view'
  'jquery'
  'app/views/profile.view'
  'app/models/user'
  'app/templates/login_register/login'
  'szm'
], (CompositeView, $, ProfileView, User, LoginTemplate, Szm)->
  
  window.my_window = new Szm()
  
  class LoginView extends CompositeView
    
    tagName: 'section'
    id: 'login-view'

    initialize: (options)->
      loginTemplate = JST['app/templates/login_register/login'] 
      @$el.html loginTemplate

    events:
      'click #login-view-submit': 'login'
      'click .login-view-register': 'navRegister'

    login: ->
      email = @$el.find('input[name="email"]').val()
      password = @$el.find('input[name="password"]').val()
      loginData =
        login: email
        password: password
        get_json: true
      $('#loading').show()
      @model.save loginData,
        wait: true
        success: this.successCreate
    
    successCreate: (model, response, options) ->
      data = response.data
      if data.error_message
        alert data.error_message
      else
        user = data.user
        console.info data.user
        window.localStorage.setItem('userAccessToken', user.token) 
        window.localStorage.setItem('userId', user.id)
        window.localStorage.setItem('userEmail', user.email) 
        $('#notice').empty()
        App.router.logged_in()
        App.router.home()
      $('#loading').hide()

    navRegister: ->
      window.App.router.register()
