$ ->
  if $('.js-to-top').lengthlength > 0
    $(window).scroll ->
      if $(this).scrollTop() > 0
        $('.js-to-top').addClass('is-active')
      else
        $('.js-to-top').removeClass('is-active')
