$(function() {
  $(".js-target-blank a").click(function() {
    window.open(this.href, "");
  });
});
