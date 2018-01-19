import 'whatwg-fetch'

document.addEventListener('DOMContentLoaded', () => {
  if (!document.getElementById('canvas')) { return null; }

  let canvas = document.getElementById('canvas');
  let ctx = canvas.getContext('2d');
  let video = document.createElement('video');
  const constraints = { audio: false, video: true };

  const postImage = () => {
    ctx.drawImage(video, 0, 0);

    canvas.toBlob((blob) => {
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
      }).catch((error) => {
        console.warn(error)
      })
    }, 'image/jpeg', 0.95);
  }

  const startVideo = () => {
    navigator.mediaDevices.getUserMedia(constraints).then((stream) => {
      video.srcObject = stream;

      video.onloadedmetadata = (e) => {
        const width = video.videoWidth;
        const height = video.videoHeight;
        canvas.setAttribute('width', width);
        canvas.setAttribute('height', height);

        postImage();
        setInterval(postImage, 60 * 1000);
      };
    }).catch(function(err) {
      console.log(err);
    });
  }

  startVideo();
});
