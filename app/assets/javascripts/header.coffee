$ ->
  if $('.js-header').length > 0
    $(window).scroll ->
      if $(this).scrollTop() > $('.main-visual__main').offset().top + $('.main-visual__main').outerHeight()
        $('.js-header').addClass('is-fixed')
      else
        $('.js-header').removeClass('is-fixed')
