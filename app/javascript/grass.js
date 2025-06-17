document.addEventListener('DOMContentLoaded', () => {
  const hideGrass = document.querySelector('.js-hide-grass')
  const grassContainer = hideGrass?.closest('.a-card')

  if (hideGrass && grassContainer) {
    hideGrass.addEventListener('click', () => {
      document.cookie = `user_grass=hidden; path=/;`
      grassContainer.style.display = 'none'
    })
  }
})
