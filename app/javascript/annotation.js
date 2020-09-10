document.addEventListener('DOMContentLoaded', () => {
  const annotationIcon = document.querySelectorAll('.annotation__icon')
  const modal = document.querySelector('#js-annotation-modal')
  const divOverlay = document.createElement('div')
  divOverlay.id = 'annotation-modal__overlay'

  window.addEventListener('click', (e) => {
    const overlay = document.querySelector('#annotation-modal__overlay')
    annotationIcon.forEach(value => {
      if (overlay && e.target.parentNode !== modal) {
        modal.style.display = 'none'
        modal.classList.remove('annotation-modal')
        document.body.removeChild(divOverlay)
      } else if (e.target === value) {
        modal.style.display = 'inline-block'
        modal.classList.add('annotation-modal')
        document.body.appendChild(divOverlay)
        modal.innerHTML = value.innerHTML
      }
    })
  })
})
