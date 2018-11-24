$(function() {
  $('.js-modal').click(function(){
    var modalId = $(this).data('target');
    var target = $(modalId)
    target.addClass('is-active').append('<div class="modal__overlay js-modal__close"></div>');
    $(body).addClass('is-shown-modal');
  });
});

$(document).on('click', '.js-modal__close', function () {
  $('.modal').removeClass('is-active');
  $('.modal__overlay').remove();
  $(body).removeClass('is-shown-modal');
});
