document.addEventListener('DOMContentLoaded', () => {
  const dropdownMenu = document.querySelector('.js-header-dropdown');

  if (!dropdownMenu) {
    console.warn('.js-header-dropdown not found');
    return;
  }

  document.addEventListener('click', (event) => {
    if (!dropdownMenu.contains(event.target)) {
      dropdownMenu.classList.remove('is-opened-dropdown');
    }
  });

  dropdownMenu.addEventListener('click', () => {
    if (dropdownMenu.classList.contains('is-opened-dropdown')) {
      dropdownMenu.classList.remove('is-opened-dropdown');
    } else {
      dropdownMenu.classList.add('is-opened-dropdown');
    }
  });
});
