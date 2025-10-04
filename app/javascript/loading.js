const hideLoading = () => {
  const loading = document.getElementById('loading-screen')
  const body = document.getElementById('loading-body')

  if (loading && body) {
    loading.style.display = 'none'
    body.style.removeProperty('display')
  }
}

window.addEventListener('load', hideLoading)
document.addEventListener('turbo:load', hideLoading)
