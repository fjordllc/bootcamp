$ ->
  $(".js-open-welcome-global-nav").click ->
    $(".js-open-welcome-global-nav__target").addClass("is-active")
    $(".js-close-welcome-global-nav").addClass("is-active")
    $("body").addClass("is-mobile-nav-active")

  $(".js-close-welcome-global-nav").click ->
    $(".js-close-welcome-global-nav__target").removeClass("is-active")
    $(".js-close-welcome-global-nav__overlay").removeClass("is-active")
    $("body").removeClass("is-mobile-nav-active")
