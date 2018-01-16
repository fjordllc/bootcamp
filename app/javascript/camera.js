import 'whatwg-fetch'

document.addEventListener('DOMContentLoaded', () => {
  const startVideo = () => {
    let video = document.createElement('video');
    let canvas = document.getElementById('canvas');
    let ctx = canvas.getContext('2d');
    const constraints = { audio: false, video: { width: 320, height: 240 } };

    navigator.mediaDevices.getUserMedia(constraints).then((stream) => {
      video.srcObject = stream;

      video.onloadedmetadata = (e) => {
        const width = video.videoWidth;
        const height = video.videoHeight;
        canvas.setAttribute('width', width);
        canvas.setAttribute('height', height);

        setInterval(() => {
          const aspect = width / height;
          ctx.drawImage(video, 0, 0, 320, 320 / aspect);

          canvas.toBlob((blob) => {
            postImage(blob);
          }, 'image/jpeg', 0.95);
        }, 1 * 60 * 1000);
      };
    }).catch(function(err) {
      console.log(err);
    });
  }

  const postImage = (blob) => {
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
  }

  startVideo();
});
