function dispatchAddTagEvent(tag, retries = 20) {
  const tagifyScope = document.querySelector('.tagify')

  if (tagifyScope) {
    const event = new CustomEvent('add-tag-from-shortcut', {
      detail: { tag },
      bubbles: true
    })
    tagifyScope.dispatchEvent(event)
  }

  if (retries > 0) {
    setTimeout(() => dispatchAddTagEvent(tag, retries - 1), 50)
  }
}

function setupTagShortcut() {
  document.querySelectorAll('.js-tag-input-button').forEach((button) => {
    if (button.dataset.tagShortcutInitialized === 'true') return

    button.dataset.tagShortcutInitialized = 'true'
    button.addEventListener('click', () => {
      dispatchAddTagEvent(button.dataset.tag)
    })
  })
}

document.addEventListener('turbo:load', setupTagShortcut)
setupTagShortcut()
