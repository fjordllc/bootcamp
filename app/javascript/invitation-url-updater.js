document.addEventListener('DOMContentLoaded', async () => {
  const invitationElements = Array.from(
    document.querySelectorAll('.invitation-elements select')
  )
  const invitationUrl = document.querySelector('.js-invitation-url')
  const invitationUrlText = document.querySelector('.js-invitation-url-text')

  if (!invitationElements || !invitationUrl) {
    return
  }

  const updateInvitationURL = async () => {
    const invitationCompany = document.querySelector('.js-invitation-company')
    const invitationRole = document.querySelector('.js-invitation-role')
    const invitationCourse = document.querySelector('.js-invitation-course')

    const params = new URLSearchParams()
    params.append(
      'company_id',
      invitationCompany.options[invitationCompany.selectedIndex].value
    )
    params.append(
      'role',
      invitationRole.options[invitationRole.selectedIndex].value
    )
    params.append(
      'course_id',
      invitationCourse.options[invitationCourse.selectedIndex].value
    )

    const response = await fetch(
      `/api/admin/invitation_url?${params.toString()}`
    ).catch((error) => console.warn(error))
    const json = await response.json().catch((error) => console.warn(error))

    invitationUrl.href = json.url
    invitationUrlText.value = json.url
  }

  invitationElements.forEach((invitationElement) => {
    invitationElement.addEventListener('change', updateInvitationURL)
  })

  window.addEventListener('pageshow', updateInvitationURL)
})
