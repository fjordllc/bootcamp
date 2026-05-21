function setupHibernationAgreements() {
  const checkbox = document.querySelector('.js-hibernation-agreements-checkbox')
  const submit = document.querySelector('.js-hibernation-agreements-submit')

  if (!checkbox) return
  if (!submit) return
  if (checkbox.dataset.hibernationAgreementsInitialized === 'true') return

  checkbox.dataset.hibernationAgreementsInitialized = 'true'
  checkbox.addEventListener('change', () => {
    if (checkbox.checked) {
      submit.classList.remove('is-disabled')
      submit.classList.add('is-danger')
    } else {
      submit.classList.add('is-disabled')
      submit.classList.remove('is-danger')
    }
  })
}

document.addEventListener('turbo:load', setupHibernationAgreements)
document.addEventListener('DOMContentLoaded', setupHibernationAgreements)
setupHibernationAgreements()
