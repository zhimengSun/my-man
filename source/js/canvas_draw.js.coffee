define ['backbone','jquery'], (Backbone, $) ->

  class window.CanvasDraw

    constructor: (e, stylesOpts) ->
      @canvas = document.getElementById(e)
      @canvas.height = stylesOpts.height
      @canvas.width = stylesOpts.width
      @ctx = @canvas.getContext("2d")
      @canvas.addEventListener('touchend', @ended, false)
      ['mouseup','mousedown','mousemove','touchstart','touchmove'].forEach (ename) =>
        @canvas.addEventListener(ename, @dragDraw, false) if ename.match 'mouse'
        @canvas.addEventListener(ename, @touchDraw, false) if ename.match 'touch'
      @current_dialog = '#draw_style'

    drawStyle: (canvasOpts) ->
      @ctx.fillStyle = canvasOpts.fill
      @ctx.strokeStyle = canvasOpts.color
      @ctx.lineWidth = canvasOpts.size
      @ctx.lineCap = "round"
    
    getStyle: ->
      color: @ctx.strokeStyle
      size: @ctx.lineWidth
    
    toggleStyle: (options) ->
      styles = options.styles
      dtype = options.dtype || 'color'
      for j in [0..styles.length-1]
        style = styles.eq(j)
        value = style.html() if dtype is 'color'
        if options.index == j
          style.css
            border: '2px #fff solid'
        else
          style.css
            border: '2px ' + value + ' solid'

    ended: =>
      # @saveToPng() if window.isDraw

    saveToPng: =>
      $.ajax
        url: App.apiHost + "/save_png"
        type: 'post'
        data:
          token: currentUser.get('token')
          doc_id: currentDoc.id
          png: @canvas.toDataURL("image/png").replace('data:image/png;base64,','')

    touchDraw: (event) =>
      coors = @getMousePosition(event, 'touch')
      @draw(coors, event.type) if window.isPresenting

    dragDraw: (event) =>
      coors = @getMousePosition(event, 'drag')
      @draw(coors, event.type) if window.isPresenting
    
    getMousePosition: (e, dtype) ->
      if dtype is 'touch'
        pageP =
          x: event.targetTouches[0].pageX
          y: event.targetTouches[0].pageY
      if dtype is 'drag'
        pageP =
          x: e.pageX
          y: e.pageY
      x: pageP.x - @canvas.offsetLeft
      y: pageP.y - @canvas.offsetTop 

    beginDraw: =>
      window.isDraw = true
      window.isEraser = false

    beginHammer: =>
      window.isDraw = false
      $('#toggleTool').show()
      @hideDrawStyle()
    
    clear: ->
      @ctx.clearRect(0, 0, @canvas.width, @canvas.height)
          
    draw: (position, type, draw_styles = {}) ->
      if !window.isPresenting
        @drawStyle(draw_styles)
      x = position.x
      y = position.y
      if window.isDraw or !window.isPresenting
        if type is "mousedown" or type is "touchstart"
          @hideDrawStyle()
          window.isPaint = true
          @ctx.beginPath()
          @ctx.moveTo(x, y)
        else if type is "mousemove" or type is "touchmove"
          if window.isPaint
            @ctx.lineTo(x, y)
            @ctx.stroke()
            @ctx.globalCompositeOperation = "source-over"
            if window.isEraser
              @ctx.globalCompositeOperation = "destination-out"
              @ctx.arc(x, y, 0, 0, Math.PI * 2, false)
              @ctx.fill()
              draw_styles.is_eraser = true
        else if type is 'mouseup' or type is 'touchend'
          window.isPaint = false
          # @saveToPng()
          @endSync()
          @ctx.closePath()
        @publishData(position, type, currentDoc.id, @getStyle()) if window.isPaint
       
    beginSync: ->
      @sync = 
        setInterval ->
          @saveToPng()
        , 200

    endSync: ->
      clearInterval(@sync) if @sync

    clearCanvas: ->
      @clear()
      @publishAction('clear')

    clearHistory: ->
      $('#saved_png').html('')
      @publishAction('clearHistory')
    
    deleteHistory: ->
      if isPresenting
        @clearHistory()
        @clearCanvas()
        $.ajax
          url: App.apiHost + '/delete_history'
          type: 'post'
          data:
            id: currentDoc.id
            token: currentUser.get('token')

    publishAction: (action, doc_id = currentDoc.id, user_id = currentUser.id) ->
      if isPresenting or action is 'apply_presenter'
        faye.publish Channel,
          id: doc_id
          user_id: user_id
          dtype: action

    publishData: (position, dtype, doc_id = currentDoc.id, draw_style = {}) ->
      if isPresenting
        faye.publish Channel,
          id: doc_id
          position: position
          dtype: dtype
          draw_style: draw_style

    sync_page: (url) ->
      $.ajax
        url: App.apiHost + url
        type: 'post'
        data:
          token: currentUser.get('token')
      .done (data) =>
        @slidePage(data.data)
    
    window.out_first_page = false
    window.out_last_page = false
    
    imagePath: ->
      App.apiHost # request static sources directly
      # cached image if have

    slidePage: (doc) ->
      $('#base_png').attr('src', @imagePath() + doc.image_url)

      historyPngs = ''
      $.each doc.history_pngs, (i, v) ->
        historyPngs += '<img src="' + @imagePath() + v.replace('public','') + '" >'

      $('#saved_png').html(historyPngs)
      
      currentDoc.set
        cur_page: doc.cur_page
      $('#page_no').html(doc.cur_page + "/" + doc.page_count)

      @publishAction('prev', doc.id)
      @firstOrLastPage(doc)
    
    sync_page_with_cache: (doc, direction) ->
      alert doc.name
      alert direction

    firstOrLastPage: (doc, dtype = '') ->
      if window.isPresenting or dtype is 'cache'
        if doc.cur_page == doc.page_count
          @hideSlideButton('next')
          @alert '已经到最后一页' if out_last_page
          window.out_last_page = true
        else if doc.cur_page == 1
          @hideSlideButton('prev')
          @alert '已经到第一页' if out_first_page
          window.out_first_page = true
        else
          @showAllSlideButton()
          window.out_first_page = false
          window.out_last_page = false

      # @clearCanvas()
      @deleteHistory() # 一次性删除该页所有划线包括当前和历史
    
    hideSlideButton: (direction) ->
      $('#' + direction).hide()
      $('#' + direction).css
        'z-index': 110

    showSlideButton: (direction) ->
      $('#' + direction).show()
      $('#' + direction).css
        'z-index': 1000
    
    showAllSlideButton: ->
      @showSlideButton('next')
      @showSlideButton('prev')

    hideAllSlideButton: ->
      @hideSlideButton('next')
      @hideSlideButton('prev')

    setPresenter: (presenterId = currentUser.id) ->
      window.isPresenting = true
      window.isDraw = false
      window.isPaint = false
      @ctx.closePath()
      App.tool_helper.ctrlButtons().slideDown()
      @hideModal()
      # enter_view.current_menu = $($('#enterPage').find('.btn')[0])
      if isHost
        $('#presenters').css
          top: 189
        .find('.caret').css
          top: 220
        $('#docs_dialog').css
          top: 139
        .find('.caret').css
          top: 200
        @showHostNeedButtons()
        presenters_view.current_presenter.find('.current_presenter_icon').removeClass('current_presenter_icon')
      else
        $('#draw_style').css
          top: 100
      @hideStartPresentBtn()
      $.ajax
        url: App.apiHost + '/set_presenter'
        type: 'post'
        data:
          token: currentUser.get('token')
          meeting_id: currentMeeting.id
          presenter_id: presenterId
      .done (r) =>
        @publishPresenterTo(r.data, 'end_other_presenters')
    
    stopPresenter: (presenterId = currentUser.id) ->
      window.isPresenting = false
      App.tool_helper.ctrlButtons().slideUp()
      @showModal()
      $.ajax
        url: App.apiHost + '/set_presenter'
        type: 'post'
        data:
          token: currentUser.get('token')
          meeting_id: currentMeeting.id
          presenter_id: presenterId
          exit: true
      .done (r) =>
        @publishPresenterTo(r.data)
    
    applyPresenter: ->
      $.ajax
        url: App.apiHost + '/apply_presenter'
        type: 'post'
        data:
          token: currentUser.get('token')
          meeting_id: currentMeeting.id
          apply_user_id: currentUser.id
      .done (r) =>
        faye.publish Channel,
          dtype: 'apply_presenter'
          user: r.data
     
    offPresenter: ->
      if isHost
        @hideHostNeedButtons()
        $('#presenters').hide()
      else
        App.tool_helper.ctrlButtons().slideUp() 
      window.isPresenting = false
      window.isDraw = false
      $('#canvas').show()
      @showModal()
    
    hideHostNeedButtons: ->
      App.tool_helper.commonPresentMenus().slideUp()

    showHostNeedButtons: ->
      App.tool_helper.commonPresentMenus().slideDown()

    publishPresenterTo: (presenter, dtype = 'change_presenter') ->
      faye.publish Channel,
        dtype: dtype
        user_id: presenter.id
        user_name: presenter.name
      
    showStartPresentBtn: ->
      $("#start_present").show() if $('#start_present').html() != '开启共享'

    hideStartPresentBtn: ->
      $("#start_present").hide()

    hideModal: ->
      $('#modal').hide()
      @showStartPresentBtn()
      $("#exit_present").show()
      $("#apply_present").hide()

    showModal: ->
      $('#modal').show() #if _.include(presenters_view.collection.models, currentUser)
      $("#exit_present").hide()
      if isHost
        $("#start_present").html("收回演示")
        @showStartPresentBtn()
      else
        $("#start_present").hide()
      if isPresenting
        @showAllSlideButton()
      else
        @hideAllSlideButton()

      $("#apply_present").show()
    
    hidePresenters: ->
      $("#presenters").hide()
        
    hideDrawStyle: ->
      $("#draw_style").hide()
    
    hideDocsDialog: ->
      $("#docs_dialog").hide()
    
    hideAllOnModal: ->
      $("#alert").hide()
      if currentDoc.get('cur_page') is 1
        @hideSlideButton('prev')
      else
        @showSlideButton('prev') if isPresenting
      @hideDrawStyle()
      # @resetAlert()
      @hidePresenters()
      @hideDocsDialog()
      if isPresenting
        $("#modal").hide()

    alert: (content, title = '国信会议系统') ->
      App.tool_helper.alert content, title

    toggleModal: (dialog = '#draw_style') ->
      draw_style = $('#draw_style').css('display')
      presenters = $('#presenters').css('display')
      docs = $('#docs_dialog').css('display')
      if draw_style is 'block' or presenters is 'block' or docs is 'block'
        $('#modal').show()
        @hideSlideButton('prev')
        $(@current_dialog).hide()
        @current_dialog = dialog
        $(@current_dialog).show()
      if draw_style is 'none' and presenters is 'none' and docs is 'none'
        $('#modal').hide()
        @showSlideButton('prev') if currentDoc.get('cur_page') != 1

    promote: (data) ->
      presenter = data.user
      $('#modal').show()
      $('#presenters').show()
      $('#presenter_list .icons').each ->
        if $(this).attr('data-id') == presenter.id.toString()
          $(this).find('.refuse_presenter').show()
          $(this).find('.set_presenter').show()
    
    setCurrentDoc: (doc) ->
      currentMeeting.set('cur_doc_id', doc.id)
      currentMeeting.save
        patch: true
      currentDoc.set doc
      image = App.apiHost + '/meeting_root/' + currentMeeting.id + '/doc_' + doc.id + '/1/1.jpg'
      $('#base_png').attr('src', image)
      @deleteHistory()
      if isHost
        $('#page_no').html('1/' + doc.get('page_count'))
      else
        $('#page_no').html('1/' + doc.page_count)

    pushToHost: (dtype, user = currentUser) ->
      if !isHost
        faye.publish Channel,
          dtype: dtype
          user: user
        if dtype is 'user_leave'
          $.ajax
            url: App.apiHost + '/meetings/' + currentMeeting.id + '/leave'
            type: 'post'
            data:
              id: currentMeeting.id
              token: currentUser.get('token')
    
    updatePresentersView: (dtype, user) ->
      # @pushToHost(dtype, user)
      if dtype is 'user_leave'
        presenters_view.collection.remove user
      if dtype is 'user_join'
        presenters_view.collection.add user
      presenters_view.render()

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
    
    setHost: (user_id) ->
      # @alert 'now I am the host'
      window.isHost = true
      App.tool_helper.ctrlButtons().slideDown()
      App.tool_helper.hostOnlyMenus().slideDown()
      $('#apply_present').slideUp()
      $('#follow_or_free').slideUp()
    
    stopHost: ->
      window.isHost = false
      App.tool_helper.ctrlButtons().slideUp()
      App.tool_helper.hostOnlyMenus().slideUp()
      $('#apply_present').slideDown()
      $('#follow_or_free').slideDown()
