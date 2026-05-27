const isApplePlatform = () => {
  const userAgent = navigator.userAgent.toLowerCase()
  return /mac|iphone|ipad|ipod/.test(userAgent)
}

const isModifierPressed = (event) =>
  isApplePlatform() ? event.metaKey : event.ctrlKey

const isEditableTarget = (target) =>
  target instanceof HTMLElement &&
  (target.isContentEditable ||
    ['INPUT', 'TEXTAREA', 'SELECT'].includes(target.tagName))

const canInsertText = (target) =>
  typeof target.selectionStart === 'number' &&
  typeof target.selectionEnd === 'number'

const clickButton = (selector) => {
  const button = document.querySelector(selector)
  if (!button) return false

  button.click()
  return true
}

const insertUserIconTag = (textarea) => {
  const loginName = textarea.dataset.loginName
  if (!loginName) return false

  const userIconTag = `:@${loginName}: `
  const start = textarea.selectionStart
  const end = textarea.selectionEnd
  textarea.value =
    textarea.value.slice(0, start) + userIconTag + textarea.value.slice(end)
  textarea.selectionStart = textarea.selectionEnd = start + userIconTag.length
  return true
}

document.addEventListener('keydown', (event) => {
  if (event.isComposing || event.keyCode === 229) return
  if (!isModifierPressed(event)) return

  const key = event.key.toLowerCase()
  const editable = isEditableTarget(event.target)

  if (editable && key === 's') {
    event.preventDefault()
    clickButton('#js-shortcut-wip')
    return
  }

  if (editable && key === 'enter') {
    event.preventDefault()
    clickButton('#js-shortcut-submit,#js-shortcut-post-comment')
    return
  }

  if (key === 'e') {
    if (clickButton('#js-shortcut-edit')) event.preventDefault()
    return
  }

  if (key === 'b') {
    const clicked =
      clickButton('#js-shortcut-check') ||
      clickButton('#js-shortcut-unconfirmed-links-open')
    if (clicked) event.preventDefault()
    return
  }

  if (editable && key === 'i' && canInsertText(event.target)) {
    if (insertUserIconTag(event.target)) event.preventDefault()
  }
})
