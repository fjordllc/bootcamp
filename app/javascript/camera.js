import 'whatwg-fetch'

document.addEventListener('DOMContentLoaded', () => {
  let video = document.querySelector('video');
  let width = video.offsetWidth;
  let height = video.offsetHeight;

  let canvas = document.getElementById('canvas');
  let ctx = canvas.getContext('2d');
  let constraints = { audio: false, video: { width: 320, height: 240 } };

  navigator.mediaDevices.getUserMedia(constraints).then((stream) => {
    video.srcObject = stream;
    video.onloadedmetadata = (e) => {
      setInterval(() => {
        canvas.setAttribute('width', width);
        canvas.setAttribute('height', height);
        ctx.drawImage(video, 0, 0, width, height);

        canvas.toBlob((blob) => {
          let img = new Image();
          img.src = window.URL.createObjectURL(blob);

          let params = new FormData();
          params.append('face', blob, 'face.jpg');

          fetch('/api/face', {
            method: 'PUT',
            headers: {
              'X-Requested-With': 'XMLHttpRequest',
              'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
            },
            credentials: 'same-origin',
            body: params
          }).then((response) => {
            return response.json();
          }).then((json) => {
            const url = json['url'];
            console.log('url: ' + url);
          }).catch((error) => {
            console.warn('parsing failed', error)
          })
        }, 'image/jpeg', 0.95);

      }, 5000);

    };
  }).catch(function(err) {
    console.log(err);
  });
});
