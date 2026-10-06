document.addEventListener('DOMContentLoaded', () => {
  const invitationElements = Array.from(
    document.querySelectorAll('.invitation__element select')
  )
  const invitationUrl = document.querySelector('.js-invitation-url')
  const invitationUrlText = document.querySelector('.js-invitation-url-text')

  if (invitationElements.length === 0 || !invitationUrlText || !invitationUrl) {
    return
  }

  let requestSequence = 0

  const updateInvitationURL = async () => {
    const sequence = ++requestSequence
    invitationUrl.removeAttribute('href')
    invitationUrl.setAttribute('aria-disabled', 'true')
    invitationUrlText.value = ''
    invitationUrlText.disabled = true
    invitationUrlText.placeholder = '招待URLを作成しています…'

    const endpoint =
      document.querySelector('.invitation__url').dataset.invitationUrlEndpoint
    const query = new URLSearchParams({
      company_id: document.querySelector('.js-invitation-company').value,
      role: document.querySelector('.js-invitation-role').value,
      course_id: document.querySelector('.js-invitation-course').value
    })

    try {
      const response = await fetch(`${endpoint}?${query}`, {
        credentials: 'same-origin',
        headers: { Accept: 'application/json' }
      })
      if (!response.ok) throw new Error('Invitation request failed')
      const result = await response.json()
      if (sequence !== requestSequence) return
      if (typeof result.url !== 'string' || !result.url) {
        throw new Error('Invitation URL missing')
      }

      invitationUrl.href = result.url
      invitationUrl.removeAttribute('aria-disabled')
      invitationUrlText.value = result.url
      invitationUrlText.disabled = false
      invitationUrlText.placeholder = ''
    } catch {
      if (sequence === requestSequence) {
        invitationUrlText.placeholder =
          '招待URLを作成できませんでした。再度選択してください。'
      }
    }
  }

  invitationElements.forEach((invitationElement) => {
    invitationElement.addEventListener('change', updateInvitationURL)
  })

  window.addEventListener('pageshow', updateInvitationURL)
  updateInvitationURL()
})
