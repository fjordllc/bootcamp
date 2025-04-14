document.addEventListener('DOMContentLoaded', () => {
  document.querySelectorAll('.js-tag-input-button').forEach((button) => {
    button.addEventListener('click', () => {
      const tag = button.dataset.tag
      const tagifyScope = document.querySelector('.tagify')
      if (!tagifyScope) return

      const event = new CustomEvent('add-tag-from-shortcut', {
        detail: { tag },
        bubbles: true
      })
      tagifyScope.dispatchEvent(event)
    })
  })
})
