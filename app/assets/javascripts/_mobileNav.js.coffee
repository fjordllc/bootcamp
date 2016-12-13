$ ->
  $('.js-show-mobile-nav').click ->
    if $('.js-show-mobile-nav__target').hasClass('is-active')
      $('.js-show-mobile-nav__target').removeClass('is-active')
    else
      $('.js-show-mobile-nav__target').addClass('is-active')
