document.addEventListener('DOMContentLoaded', () => {
  const elements = document.getElementsByName('register_address')
  if (!elements) {
    return null
  }

  elements.forEach( element => {
    element.addEventListener('change', () => {
      const countryForm = document.getElementById('country-form')
      const subdivisionForm = document.getElementById('subdivision-form')
      const elements = [countryForm, subdivisionForm]

      elements.forEach( element => {
        element.classList.toggle('is-hidden')
      })
    })
  })
})
