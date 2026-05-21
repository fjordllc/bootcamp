function handleLegacyLinkMethod(event) {
  const link = event.target.closest('a[data-turbo-method]')
  if (!link) return

  submitLegacyMethodLink(link, event)
}

function submitLegacyMethodLink(link, event) {
  const method = link.dataset.turboMethod
  if (!method || method.toLowerCase() === 'get') return true

  const message = link.dataset.turboConfirm
  if (message && !window.confirm(message)) {
    event.preventDefault()
    return false
  }

  event.preventDefault()

  const form = document.createElement('form')
  form.method = 'post'
  form.action = link.href
  form.dataset.turbo = 'false'
  form.style.display = 'none'

  const csrfParam = document.querySelector('meta[name="csrf-param"]')?.content
  const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content

  if (csrfParam && csrfToken) {
    form.appendChild(hiddenInput(csrfParam, csrfToken))
  }

  form.appendChild(hiddenInput('_method', method))
  document.body.appendChild(form)
  form.requestSubmit()
  return false
}

function hiddenInput(name, value) {
  const input = document.createElement('input')
  input.type = 'hidden'
  input.name = name
  input.value = value
  return input
}

window.submitLegacyMethodLink = submitLegacyMethodLink
document.addEventListener('click', handleLegacyLinkMethod)
