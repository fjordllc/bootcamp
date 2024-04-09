document.addEventListener('DOMContentLoaded', () => {
  const initializeFileInput = (target) => {
    const inputs = target.querySelectorAll('.js-movie-file-input input');
    if (!inputs) return null;

    inputs.forEach((input) => {
      input.addEventListener('change', (e) => {
        const file = e.target.files[0];

        if (file) {
          const fileReader = new FileReader();
          fileReader.addEventListener('load', (event) => {
            const dataUri = event.target.result;
            const preview = input.parentElement.querySelector('.js-movie-file-input__preview'); // プレビュー要素を選択
            const p = preview.querySelector('p');
            let movieData = preview.querySelector('video');

            if (!movieData) {
              movieData = document.createElement('video');
              movieData.setAttribute('controls', '');
              preview.appendChild(movieData);
            }

            movieData.src = dataUri;
            p.innerHTML = '動画を変更';
          });
          fileReader.readAsDataURL(file);
        }
      });
    });
  };

  initializeFileInput(document);
});
