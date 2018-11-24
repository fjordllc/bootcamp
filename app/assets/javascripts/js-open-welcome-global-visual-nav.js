$(function() {
  $(".js-open-welcome-global-nav").click(function() {
    $(".js-open-welcome-global-nav__target").addClass("is-active");
    $(".js-close-welcome-global-nav").addClass("is-active");
    return $("body").addClass("is-mobile-nav-active");
  });
  return $(".js-close-welcome-global-nav").click(function() {
    $(".js-close-welcome-global-nav__target").removeClass("is-active");
    $(".js-close-welcome-global-nav__overlay").removeClass("is-active");
    return $("body").removeClass("is-mobile-nav-active");
  });
});
