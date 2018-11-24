$(function() {
  return $('.js-drop-down__trigger').click(function() {
    if ($(this).parents('.js-drop-down').hasClass('is-active')) {
      return $(this).parents('.js-drop-down').removeClass('is-active');
    } else {
      return $(this).parents('.js-drop-down').addClass('is-active');
    }
  });
});
