$ ->
  $(".js-show-mobile-nav").click ->
    if $(".js-show-mobile-nav__target").hasClass("is-active")
      $(".js-show-mobile-nav__target").removeClass("is-active")
      $("body").removeClass("is-mobile-nav-active")
    else
      $(".js-show-mobile-nav__target").addClass("is-active")
      $("body").addClass("is-mobile-nav-active")
