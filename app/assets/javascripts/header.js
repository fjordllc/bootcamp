$(function() {
  if ($('.js-header').length > 0) {
    return $(window).scroll(function() {
      if ($(this).scrollTop() > $('.main-visual__main').offset().top + $('.main-visual__main').outerHeight()) {
        return $('.js-header').addClass('is-fixed');
      } else {
        return $('.js-header').removeClass('is-fixed');
      }
    });
  }
});
