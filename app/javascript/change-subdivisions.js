document.addEventListener('DOMContentLoaded', () => {
  const countryForm = document.getElementById('country-form')
  if (!countryForm) {
    return null
  }
  const countries = JSON.parse(countryForm.getAttribute('data-countries'))
  const countrySelect = document.getElementById('country-select')

  countrySelect.addEventListener('change', () => {
    const subdivisionSelect = document.getElementById('subdivision-select')
    const selectedCountry = countrySelect.value
    subdivisionSelect.options.length = 0

    countries[selectedCountry].forEach(subdivision => {
      const option = document.createElement('option')
      option.text = subdivision[0]
      option.value = subdivision[1]
      subdivisionSelect.appendChild(option)
    })
  })
})
