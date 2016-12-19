$ ->
  if $('.js-page-nav').length > 0
    console.log('aaaa')
    offsetTop = $('.js-page-nav').offset().top - 16
    top = $(this).scrollTop()
    $(window).scroll ->
      if $(this).scrollTop() > offsetTop
        $('.js-page-nav').css('top', $(this).scrollTop() - offsetTop)
      else
        $('.js-page-nav').css('top', 0)
