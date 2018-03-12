$(function() {
  $(".js-close-alert__trigger").click(function() {
    $(this).parents(".js-close-alert").addClass("is-hidden");
  });
});
