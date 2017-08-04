$ ->
  if $('.js-header').length > 0
    $(window).scroll ->
      if $(this).scrollTop() > 100
        $('.js-header').addClass('is-fixed')
      else
        $('.js-header').removeClass('is-fixed')
