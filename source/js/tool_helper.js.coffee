define ['backbone','jquery'], (Backbone, $) ->

  class window.ToolHelper

    alert: (content, title = '个人内部管理系统') ->
      # $("#alert .message").html(title)
      # $("#alert").show()
      # $("#modal").show()
      nsalert content, title
