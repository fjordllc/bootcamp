document.addEventListener('DOMContentLoaded', () => {
  const element = document.querySelector('.form-item__times-action > a.remove_fields.dynamic')
  if (!element) { return null }

  element.style.display = 'none'
})
