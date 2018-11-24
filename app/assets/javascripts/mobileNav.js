$(function() {
  return $(".js-show-mobile-nav").click(function() {
    if ($(".js-show-mobile-nav__target").hasClass("is-active")) {
      $(".js-show-mobile-nav__target").removeClass("is-active");
      return $("body").removeClass("is-mobile-nav-active");
    } else {
      $(".js-show-mobile-nav__target").addClass("is-active");
      return $("body").addClass("is-mobile-nav-active");
    }
  });
});
