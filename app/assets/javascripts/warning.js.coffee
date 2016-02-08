$(window).ready ->
  if $('body.reports_new').length > 0
    $('body.reports_new').on 'keyup change', ->
      $(window).on 'beforeunload', ->
        'このページを離れると、入力したデータが削除されます。本当に移動しますか？'
    $('body.reports_new').on 'submit', ->
      $(window).off 'beforeunload'

  else if $('body.reports_edit').length > 0
    $('body.reports_edit').on 'keyup change', ->
      $(window).on 'beforeunload', ->
        'このページを離れると、入力したデータが削除されます。本当に移動しますか？'
    $('body.reports_edit').on 'submit', ->
      $(window).off 'beforeunload'

  else if $('body.practices_new').length > 0
    $('body.practices_new').on 'keyup change', ->
      $(window).on 'beforeunload', ->
        'このページを離れると、入力したデータが削除されます。本当に移動しますか？'
    $('body.practices_new').on 'submit', ->
      $(window).off 'beforeunload'

  else if $('body.practices_edit').length > 0
    $('body.practices_edit').on 'keyup change', ->
      $(window).on 'beforeunload', ->
        'このページを離れると、入力したデータが削除されます。本当に移動しますか？'
    $('body.practices_edit').on 'submit', ->
      $(window).off 'beforeunload'

  else if $('body.users_new').length > 0
    $('body.users_new').on 'keyup change', ->
      $(window).on 'beforeunload', ->
        'このページを離れると、入力したデータが削除されます。本当に移動しますか？'
    $('body.users_new').on 'submit', ->
      $(window).off 'beforeunload'

  else if $('body.users_edit').length > 0
    $('body.users_edit').on 'keyup change', ->
      $(window).on 'beforeunload', ->
        'このページを離れると、入力したデータが削除されます。本当に移動しますか？'
    $('body.users_edit').on 'submit', ->
      $(window).off 'beforeunload'
