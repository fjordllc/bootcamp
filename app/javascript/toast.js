import { toast } from './vanillaToast.js'

function setupToast() {
  const messages = document.querySelectorAll('.js-toast')
  messages.forEach((element) => {
    if (element.dataset.toastInitialized === 'true') return

    element.dataset.toastInitialized = 'true'
    const message = element.dataset.message
    const type = element.dataset.type

    toast(message, type)
  })
}

document.addEventListener('turbo:load', setupToast)
document.addEventListener('DOMContentLoaded', setupToast)
setupToast()
