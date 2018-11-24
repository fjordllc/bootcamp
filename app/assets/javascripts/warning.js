$(function() {
  $('.js-warning-form').on('keyup change', function() {
    return $(window).on('beforeunload', function() {
      return 'このページを離れると、入力したデータが削除されます。本当に移動しますか？';
    });
  });
  return $(this).on('submit', function() {
    return $(window).off('beforeunload');
  });
});
