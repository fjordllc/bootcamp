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

      const value = document.querySelector('input:checked[name=register_address]').value
      const countrySelect = document.getElementById('country-select')

      if (value === 'yes') {
        if (countrySelect.value === '') {
          countrySelect.querySelector("option[value='JP']").selected = true
        }
      }
    })
  })
})
