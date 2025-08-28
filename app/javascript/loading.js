window.addEventListener('load', function () {
  const loading = document.getElementById('loading-screen')
  const body = document.getElementById('loading-body')
  
  if (loading) {
    loading.style.display = 'none'
    body.style.removeProperty('display')
  }
});
