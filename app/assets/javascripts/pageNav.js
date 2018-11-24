$(function() {
  var offsetTop, top;
  if ($('.js-page-nav').length > 0) {
    offsetTop = $('.js-page-nav').offset().top - 16;
    top = $(this).scrollTop();
    return $(window).scroll(function() {
      if ($(this).scrollTop() > offsetTop) {
        return $('.js-page-nav').css('top', $(this).scrollTop() - offsetTop);
      } else {
        return $('.js-page-nav').css('top', 0);
      }
    });
  }
});
