document.addEventListener('DOMContentLoaded', async () => {
  const invitationElements = Array.from(
    document.querySelectorAll('.invitation__element select')
  )
  const invitationUrl = document.querySelector('.js-invitation-url')
  const invitationUrlText = document.querySelector('.js-invitation-url-text')

  if (invitationElements.length === 0 || !invitationUrlText || !invitationUrl) {
    return
  }

  const updateInvitationURL = async () => {
    const invitationCompany = document.querySelector('.js-invitation-company')
    const invitationRole = document.querySelector('.js-invitation-role')
    const invitationCourse = document.querySelector('.js-invitation-course')

    const selectedCompanyId =
      invitationCompany.options[invitationCompany.selectedIndex].value
    const selectedRole =
      invitationRole.options[invitationRole.selectedIndex].value
    const selectedCourseId =
      invitationCourse.options[invitationCourse.selectedIndex].value

    const invitationUrlTemplate =
      document.querySelector('.invitation__url').dataset.invitationUrlTemplate
    const targetUrl = invitationUrlTemplate
      .replace(/company_id=[^&]*/, `company_id=${selectedCompanyId}`)
      .replace(/role=[^&]*/, `role=${selectedRole}`)
      .replace(/course_id=[^&]*/, `course_id=${selectedCourseId}`)

    invitationUrl.href = targetUrl
    invitationUrlText.value = targetUrl
  }

  invitationElements.forEach((invitationElement) => {
    invitationElement.addEventListener('change', updateInvitationURL)
  })

  window.addEventListener('pageshow', updateInvitationURL)
})
