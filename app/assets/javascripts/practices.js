$(function() {
  if ($('body.courses-practices-index').length > 0) {
    $('.js-category-practices').on('click', '.js-practice-state', {}, function() {
      var practice_id, ref, status, tr, x;
      status = $(this).data('status');
      tr = $(this).parents('.js-practice');
      ref = tr[0].id.split('_'), x = ref[0], practice_id = ref[1];
      console.log(tr);
      tr.find('.is-active').removeClass('is-active');
      $(this).parent().addClass('is-active');
      return $.ajax("/api/practices/" + practice_id + "/learning", {
        type: 'PUT',
        data: {
          practice_id: practice_id,
          status: status
        }
      }).done((function(_this) {
        return function() {
          $('.js-practice-state:disabled', tr).attr('disabled', false).removeClass('is-button-simple-xs-primary').addClass('is-button-simple-xs-secondary');
          return $(_this).attr('disabled', true).addClass('is-button-simple-xs-primary');
        };
      })(this));
    });
  }
  return $(".js-target-blank a").click(function() {
    window.open(this.href, "");
    return false;
  });
});
