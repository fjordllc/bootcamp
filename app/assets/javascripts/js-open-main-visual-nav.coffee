$ ->
  $(".js-open-main-visual-nav").click ->
    $(".js-open-main-visual-nav__target").addClass("is-active")
    $(".js-close-main-visual-nav").addClass("is-active")

  $(".js-close-main-visual-nav").click ->
    $(".js-close-main-visual-nav__target").removeClass("is-active")
    $(".js-close-main-visual-nav__overlay").removeClass("is-active")
