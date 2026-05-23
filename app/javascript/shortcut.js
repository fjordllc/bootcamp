import hotkeys from 'hotkeys-js'

hotkeys.filter = function (event) {
  const tagName = (event.target || event.srcElement).tagName
  hotkeys.setScope(
    /^(INPUT|TEXTAREA|SELECT)$/.test(tagName) ? 'input' : 'other'
  )
  return true
}

function isMac() {
  return navigator.userAgent.toLowerCase().indexOf('mac') > 0
}

const ctrl = isMac() ? '⌘' : 'ctrl'

hotkeys(`${ctrl}+s`, 'input', function (event, handler) {
  console.log(handler.key)
  event.preventDefault()
  const button = document.querySelector('#js-shortcut-wip')
  if (button) {
    button.click()
  }
})

hotkeys(`${ctrl}+enter`, 'input', function (event, handler) {
  console.log(handler.key)
  event.preventDefault()
  const button = document.querySelector(
    '#js-shortcut-submit,#js-shortcut-post-comment'
  )
  if (button) {
    button.click()
  }
})

hotkeys(`${ctrl}+e`, 'all', function (event, handler) {
  console.log(handler.key)
  event.preventDefault()
  const button = document.querySelector('#js-shortcut-edit')
  if (button) {
    button.click()
  }
})

hotkeys(`${ctrl}+b`, 'all', function (event, handler) {
  console.log(handler.key)
  event.preventDefault()
  const button = document.querySelector('#js-shortcut-check')
  if (button) {
    button.click()
  }

  const allOpenButton = document.querySelector(
    '#js-shortcut-unconfirmed-links-open'
  )
  if (allOpenButton) {
    allOpenButton.click()
  }
})

hotkeys(`${ctrl}+i`, 'input', function (event, handler) {
  console.log(handler.key)
  event.preventDefault()
  const textarea = event.target
  const loginName = textarea.dataset.loginName
  if (!loginName) return
  const userIconTag = `:@${loginName}: `
  const start = textarea.selectionStart
  const end = textarea.selectionEnd
  textarea.value =
    textarea.value.slice(0, start) + userIconTag + textarea.value.slice(end)
  textarea.selectionStart = textarea.selectionEnd = start + userIconTag.length
})
