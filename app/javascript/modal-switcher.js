document.addEventListener('DOMContentLoaded', () => {
  const modalSearch = document.querySelector('.modal#js-modal-search')
  const modalSearchShownTriggers = document.querySelectorAll(
    '.js-modal-search-shown-trigger'
  )
  const modalSearchHiddenTriggers = document.querySelectorAll(
    '.js-modal-search-hidden-trigger'
  )

  const switchModal = (modal) => {
    modal.classList.toggle('is-shown')
  }

  const addSwitchEvent = (triggers, modal) => {
    for (let i = 0; i < triggers.length; i++) {
      triggers[i].addEventListener('click', () => {
        switchModal(modal)
      })
    }
  }

  addSwitchEvent(modalSearchShownTriggers, modalSearch)
  addSwitchEvent(modalSearchHiddenTriggers, modalSearch)
})
