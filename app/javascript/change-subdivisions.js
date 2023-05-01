document.addEventListener('DOMContentLoaded', () => {
  const countryForm = document.getElementById('country-form')

  if (!countryForm) {
    return null
  }

  const countries = JSON.parse(countryForm.getAttribute('data-countries'))
  const countrySelect = document.getElementById('country-select')

  countrySelect.addEventListener('change', () => {
    const subdivisionSelect = document.getElementById('subdivision-select')
    const options = subdivisionSelect.options
    
    Array.from(options).forEach(option => {
      if (option.index !== 0) {
        subdivisionSelect.removeChild(options[option.index])
      }
    })

    const selectedCountry = countrySelect.value

    if (selectedCountry !== '') {
      countries[selectedCountry].forEach(subdivision => {
        const option = document.createElement('option')
        option.text = subdivision[0]
        option.value = subdivision[1]
        subdivisionSelect.appendChild(option)
      })
    }
  })
})
