$(function() {
  var target, trigger;
  trigger = $('.js-show-handle__trigger');
  target = $(this).parents('.js-show-handle').find('.js-show-handle__target');
  return $('.js-show-handle__trigger').click(function() {
    if ($(this).hasClass('is-active')) {
      $(this).parents('.js-show-handle').find('.js-show-handle__target').removeClass('is-active');
      return $(this).removeClass('is-active');
    } else {
      $(this).parents('.js-show-handle').find('.js-show-handle__target').addClass('is-active');
      return $(this).addClass('is-active');
    }
  });
});
