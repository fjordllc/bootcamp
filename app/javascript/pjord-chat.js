document.addEventListener('DOMContentLoaded', () => {
  const root = document.querySelector('[data-pjord-chat]')
  if (!root) return

  const launcher = root.querySelector('[data-pjord-chat-launcher]')
  const closeButton = root.querySelector('[data-pjord-chat-close]')
  const panel = root.querySelector('[data-pjord-chat-panel]')
  const messages = root.querySelector('[data-pjord-chat-messages]')
  const form = root.querySelector('[data-pjord-chat-form]')
  const input = root.querySelector('[data-pjord-chat-input]')
  const messagesUrl = root.dataset.messagesUrl
  let loaded = false

  const csrfToken = () =>
    document.querySelector('meta[name="csrf-token"]')?.content

  const openPanel = async () => {
    panel.hidden = false
    launcher.setAttribute('aria-expanded', 'true')
    input.focus()

    if (!loaded) {
      loaded = true
      await loadMessages()
    }
  }

  const closePanel = () => {
    panel.hidden = true
    launcher.setAttribute('aria-expanded', 'false')
    launcher.focus()
  }

  const appendMessage = ({ role, body }) => {
    const message = document.createElement('div')
    message.className = `pjord-chat__message is-${role}`
    message.textContent = body
    messages.append(message)
    messages.scrollTop = messages.scrollHeight
  }

  const showError = (body) => appendMessage({ role: 'assistant', body })

  const loadMessages = async () => {
    try {
      const response = await fetch(messagesUrl, {
        headers: { Accept: 'application/json' }
      })
      if (!response.ok) {
        showError('相談履歴を取得できませんでした。')
        return
      }

      const data = await response.json()
      if (!data.messages?.length) return

      messages.replaceChildren()
      data.messages.forEach(appendMessage)
    } catch (_error) {
      showError('相談履歴を取得できませんでした。')
    }
  }

  const setSubmitting = (submitting) => {
    input.disabled = submitting
    form.querySelector('button[type="submit"]').disabled = submitting
  }

  launcher.addEventListener('click', () => {
    if (panel.hidden) {
      openPanel()
    } else {
      closePanel()
    }
  })

  closeButton.addEventListener('click', closePanel)

  form.addEventListener('submit', async (event) => {
    event.preventDefault()

    const message = input.value.trim()
    if (!message) return

    appendMessage({ role: 'user', body: message })
    input.value = ''
    setSubmitting(true)

    try {
      const response = await fetch(messagesUrl, {
        method: 'POST',
        headers: {
          Accept: 'application/json',
          'Content-Type': 'application/json',
          'X-CSRF-Token': csrfToken()
        },
        body: JSON.stringify({ message })
      })
      const data = await response.json()

      if (response.ok) {
        appendMessage(data.assistant_message)
      } else {
        showError(
          data.message ||
            '回答を取得できませんでした。時間をおいてもう一度試してください。'
        )
      }
    } catch (_error) {
      showError(
        '通信に失敗しました。ネットワークを確認してもう一度試してください。'
      )
    } finally {
      setSubmitting(false)
      input.focus()
    }
  })
})
