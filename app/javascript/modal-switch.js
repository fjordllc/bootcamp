document.addEventListener('DOMContentLoaded', () => {
  const modal = document.querySelector('.modal#js-modal')
  const toggleModal = () => {
    modal.classList.toggle('is-shown')
  }
  const shownTriggers = document.querySelectorAll('.js-modal-shown-trigger')
  const hiddenTriggers = document.querySelectorAll('.js-modal-hidden-trigger')

  for (let i = 0; i < shownTriggers.length; i++) {
    shownTriggers[i].onclick = function(event) {
      event.target = toggleModal()
    }
  }

  for (let i = 0; i < hiddenTriggers.length; i++) {
    hiddenTriggers[i].onclick = function(event) {
      event.target = toggleModal()
    }
  }
})
