$(function() {
  var offsetTop, top;
  if ($('.js-page-nav').length > 0) {
    offsetTop = $('.js-page-nav').offset().top;
    offsetLeft = $('.js-page-nav').offset().left;
    $(window).scroll(function() {
      if ($(this).scrollTop() > offsetTop) {
        console.log(offsetTop);
        $('.js-page-nav').css('left', offsetLeft);
        $('.js-page-nav').addClass('is-sticky');
      } else {
        $('.js-page-nav').css('left', 'auto');
        $('.js-page-nav').removeClass('is-sticky');
      }
    });
  }
});
