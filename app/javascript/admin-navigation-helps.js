document.addEventListener('DOMContentLoaded', () => {
  const dropdownMenu = document.querySelector('.admin-nav-helps');
  const dropdownList = dropdownMenu.querySelector('ul');

  dropdownList.style.display = 'none';
  
  dropdownList.style.position = 'absolute';
  dropdownList.style.top = '0';
  dropdownList.style.left = '100%';

  document.addEventListener('click', (event) => {
    if (!dropdownMenu.contains(event.target)) {
      dropdownList.style.display = 'none';
    }
  });

  dropdownMenu.addEventListener('click', () => {
    if (dropdownList.style.display === 'none') {
      dropdownList.style.display = 'block';
    } else {
      dropdownList.style.display = 'none';
    }
  });
});
