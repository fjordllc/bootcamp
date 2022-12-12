document.addEventListener('DOMContentLoaded', () => {
  const modal = document.querySelector('.modal#js-modal-search.is-hidden-md-up')
  const modalSwitch = () => {
    modal.classList.toggle('is-shown')
  }
  const shownTriggers = document.querySelectorAll('.js-modal-search-shown-trigger')
  const hiddenTriggers = document.querySelectorAll('.js-modal-search-hidden-trigger')

  for (let i = 0; i < shownTriggers.length; i++) {
    shownTriggers[i].onclick = function(event) {
      event.target = modalSwitch()
    }
  }

  for (let i = 0; i < hiddenTriggers.length; i++) {
    hiddenTriggers[i].onclick = function(event) {
      event.target = modalSwitch()
    }
  }
})
