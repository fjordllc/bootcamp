$(function () {
  $('.js-file-input input').on('change', function (e) {
    var file = e.target.files[0];
    var fileReader = new FileReader();
    fileReader.onload = function () {
      var dataUri = this.result;
      $('.js-file-input__preview img').remove();
      $('.js-file-input__preview p').text("画像を変更");
      $('.js-file-input__preview').append('<img src=' + dataUri + '>');
    }
    fileReader.readAsDataURL(file);
  });
});
