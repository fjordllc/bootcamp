document.addEventListener('DOMContentLoaded', () => {
  const referralSources = document.getElementsByName('user[referral_source]')
  if (referralSources.length === 0) {
    return null
  }

  const otherReferralSource = document.getElementById(
    'user_referral_source_other'
  )
  const otherReferralSourceForm = document.getElementById(
    'other_referral_source_form'
  )
  if (otherReferralSource.checked) {
    otherReferralSourceForm.classList.remove('hidden')
  }

  referralSources.forEach((source) => {
    source.addEventListener('change', () => {
      if (otherReferralSource.checked) {
        otherReferralSourceForm.classList.remove('hidden')
      } else {
        otherReferralSourceForm.classList.add('hidden')
      }
    })
  })

  const form = document.getElementById('payment-form')
  if (form) {
    form.addEventListener('submit', validateOtherReferralSource)
  }

  function validateOtherReferralSource() {
    if (!otherReferralSource.checked) {
      const otherReferralSourceText = document.getElementById(
        'other_referral_source'
      )
      otherReferralSourceText.value = ''
    }
  }
})
