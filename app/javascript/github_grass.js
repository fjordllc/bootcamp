import 'whatwg-fetch'

document.addEventListener('DOMContentLoaded', () => {
  const selector = '.js-github-grass'
  const grasses = document.querySelectorAll(selector)
  if (grasses) {
    Array.from(grasses).forEach((grass) => {
      const name = grass.dataset.name

      fetch(`/partial/git_hub_grass?name=${name}`, {
        method: 'GET',
        headers: { 'X-Requested-With': 'XMLHttpRequest' },
        credentials: 'same-origin',
        redirect: 'manual'
      })
        .then((response) => {
          return response.text()
        })
        .then((text) => {
          grass.innerHTML = text
        })
        .then(() => {
          document
            .querySelector('.js-github-grass + .js-user-grass__loading')
            .remove()
        })
        .catch((error) => {
          console.warn(error)
        })
    })
  }
})
