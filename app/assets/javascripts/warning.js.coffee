$(window).ready ->
  body_class_name = $('body').attr('class').split('_')

  if (body_class_name[0] == 'reports' || body_class_name[0] == 'practices') && (body_class_name[1] == 'new' || body_class_name[1] == 'edit')
    obj_str = 'body.' + $('body').attr('class')

    if $(obj_str).length > 0
      $(obj_str).on 'keyup change', ->
        $(window).on 'beforeunload', ->
          'このページを離れると、入力したデータが削除されます。本当に移動しますか？'
      $(obj_str).on 'submit', ->
        $(window).off 'beforeunload'
