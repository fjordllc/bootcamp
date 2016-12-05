$ ->
  $('.js-drop-down__trigger').click ->
    if $(this).parents('.js-drop-down').hasClass('is-active')
      $(this).parents('.js-drop-down').removeClass('is-active')
    else
      $(this).parents('.js-drop-down').addClass('is-active')
