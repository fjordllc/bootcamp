$ ->
  trigger = $('.js-show-handle__trigger')
  target = $(this).parents('.js-show-handle').find('.js-show-handle__target')
  $('.js-show-handle__trigger').click ->
    if $(this).hasClass('is-active')
      $(this).parents('.js-show-handle').find('.js-show-handle__target').hide()
      $(this).removeClass('is-active')
    else
      $(this).parents('.js-show-handle').find('.js-show-handle__target').show()
      $(this).addClass('is-active')
