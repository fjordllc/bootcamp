document.addEventListener('DOMContentLoaded', () => {
  const userIconsContainer = document.querySelector('.user-icons');
  const loadingMessage = document.querySelector('.user-icons__loading');

  if (userIconsContainer && loadingMessage) {
    loadingMessage.remove();

    const moreLink = document.querySelector('.user-icons__more');
    if (moreLink) {
      moreLink.addEventListener('click', () => {
        const remainingFootprints = document.getElementById('remaining-footprints');
        const initialFootprintsContainer = document.getElementById('initial-footprints');

        while (remainingFootprints.firstChild) {
          initialFootprintsContainer.appendChild(remainingFootprints.firstChild);
        }

        moreLink.remove();
      });
    }
  }
});
