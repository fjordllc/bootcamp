document.addEventListener('DOMContentLoaded', () => {
  const moreLink = document.querySelector('.user-icons__more');
  if (moreLink) {
    moreLink.addEventListener('click', () => {
      const remainingFootprints = document.getElementById('remaining-footprints');
      remainingFootprints.style.display = 'block';
      moreLink.style.display = 'none';
    });
  }
});
