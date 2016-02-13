$(window).ready ->
  if $('.js-warning-form').length > 0
    $(this).on 'keyup change', ->
      $(window).on 'beforeunload', ->
        'このページを離れると、入力したデータが削除されます。本当に移動しますか？'
    $(this).on 'submit', ->
      $(window).off 'beforeunload'
