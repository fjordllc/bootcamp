$(function() {
  if ($('.js-to-top').length > 0) {
    return $(window).scroll(function() {
      if ($(this).scrollTop() > 0) {
        return $('.js-to-top').addClass('is-active');
      } else {
        return $('.js-to-top').removeClass('is-active');
      }
    });
  }
});
