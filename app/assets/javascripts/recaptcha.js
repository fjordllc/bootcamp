const skipOnLoadReCaptcha = (_id, _token) => {}
const onSubmitWithReCaptcha = async (e) => {
  e.preventDefault()

  const token = await window.executeRecaptchaForInquiryAsync()
  const form = e.target
  const selector = 'input[type=hidden][name^="g-recaptcha-response-data"]'
  const hidden = form.querySelector(selector)

  hidden.value = token
  form.removeEventListener('submit', onSubmitWithReCaptcha, false)
  form.submit()
}

document.addEventListener('DOMContentLoaded', () => {
  const form = document.querySelector('form')
  form.addEventListener('submit', onSubmitWithReCaptcha)
})
