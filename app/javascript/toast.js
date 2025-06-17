import { toast } from 'vanillaToast.js'

document.addEventListener('DOMContentLoaded', () => {
  const messages = document.querySelectorAll('.js-toast')
  messages.forEach((element) => {
    const message = element.dataset.message
    const type = element.dataset.type

    toast(message, type)
  })
})
