define ['backbone','jquery'], (Backbone, $) ->

  class window.ToolHelper

    alert: (content, title = '国信会议系统') ->
      # $("#alert .message").html(title)
      # $("#alert").show()
      # $("#modal").show()
      nsalert content, title

    resetAlert: ->
      $("#alert").html "
                        <div class='message'></div>
                        <div class='close'>关闭</div>
                       "

    presentMenus: ->
      $('#tools').find('.btn')
    
    ctrlButtons: ->
      $('#tools').find('.ctrl-buttons')

    commonPresentMenus: ->
      @presentMenus().slice(0,3)

    hostOnlyMenus: ->
      @presentMenus().slice(3)

    promote: (data) ->
      presenter = data.user
      $('#modal').show()
      $('#presenters').show()
      $('#presenter_list .icons').each ->
        if $(this).attr('data-id') == presenter.id.toString()
          $(this).find('.refuse_presenter').show()
          $(this).find('.set_presenter').show()
    
    exitFullScreen: ->
      window.App.full_screen = false
      $('#full_screen').html '全屏'
      $('#tools').show(1000)
      $('#pngs').animate
        height: "600px"
        width: '900px'
        left: '100px'
        top: '69px'
        background: 'transparent'
        'z-index': 1
      $('#prev').animate
        left: '75px'
      $('#next').animate
        right: '0px'
      $('#canvas').animate
        'z-index': 100
        left: '100px'
        top: '69px'
      $('#cpngs').animate
        left: '100px'
        top: '69px'
      $('#buttons').animate
        margin: '610px auto 0 440px'
      if isPresenting
        faye.publish Channel,
          dtype: 'exit_full_screen'
      else
        $('#modal').animate
          # 'z-index': 101
          top: '44px'
        $('#tools').animate
          'z-index': 1001

    fullScreen: ->
      window.App.full_screen = true
      $('#full_screen').html '退出'
      $('#tools').hide(1000)       
      $('#pngs').animate
        background: '#fff'
        'z-index': 102
        height: "100%"
        width: '100%'
        left: 0
        top: 0
      $('#prev').animate
        left: '0px'
      $('#next').animate
        right: '0px'
      $('#canvas').animate
        'z-index': 103
        left: '62px'
        top: '74px'
      $('#cpngs').animate
        left: '62px'
        top: '74px'
      $('#buttons').animate
        margin: '680 auto 0 500px'
      if isPresenting
        faye.publish Channel,
          dtype: 'full_screen'
      else
        $('#modal').animate
          'z-index': 1000
          top: 0

    dispatch: ->
      # return
      console.info 'dispatch'
      if window.show_document
        window.show_document App.apiHost, currentMeeting.id, currentDoc.id, currentUser.get('token')
      if window.isHost
        faye.publish Channel,
          dtype: 'dispatch'

    saveFileToDevice: (publish = false) ->
      console.info 'saveFileToDevice'
      # return
      if window.meeting_cache
        window.meeting_cache App.apiHost, currentMeeting.id, currentDoc.id, currentDoc.get('page_count')
      if window.isHost and publish
        faye.publish Channel,
          dtype: 'saveFileToDevice'

    subscribeToFollow: ->
      faye.subscribe Channel,
        (data) ->
          if !isPresenting
            if data.position
              canvas_draw.draw(data.position, data.dtype, data.draw_style)
              if data.draw_style.is_eraser
                window.isEraser = true
              else
                window.isEraser = false
            if data.dtype is 'prev' or data.dtype is 'next'
              canvas_draw.sync_page('/docs/' + currentDoc.id + '/slide?from=faye')
            if data.dtype is 'clear'
              canvas_draw.clear()
            if data.dtype is 'clearHistory'
              canvas_draw.clearHistory()
            if data.dtype is 'full_screen'
              App.tool_helper.fullScreen()
            if data.dtype is 'exit_full_screen'
              App.tool_helper.exitFullScreen()
            if data.dtype is 'dispatch'
              canvas_draw.dispatch()
            if data.dtype is 'saveFileToDevice'
              canvas_draw.saveFileToDevice()
          if data.user_id
            $('.user').html data.user_name
            if data.dtype is 'change_host' and data.user_id.toString() == currentUser.id.toString()
              canvas_draw.setHost(data.user_id)
            if data.dtype is 'change_document'
              canvas_draw.setCurrentDoc(data.doc) if !isHost
            if data.dtype is 'change_presenter'
              if data.user_id.toString() == currentUser.id.toString()
                canvas_draw.setPresenter(data.user_id)
              else
                canvas_draw.offPresenter()
            if data.dtype is 'end_other_presenters'
              if isHost
                # presenters_view.current_presenter.find('.current_presenter_icon').removeClass('current_presenter_icon')
              else if data.user_id.toString() != currentUser.id.toString()
                canvas_draw.offPresenter()
          if isHost
            if data.dtype is 'apply_presenter'
              canvas_draw.promote(data)
            if data.dtype is 'user_join'
              canvas_draw.updatePresentersView('user_join', data.user)
            if data.dtype is 'user_leave'
              canvas_draw.updatePresentersView('user_leave', data.user)
