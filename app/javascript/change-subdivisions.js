document.addEventListener('DOMContentLoaded', () => {
  const element = document.getElementById('js-change-subdivisions')
  if (!element) {
    return null
  }
  const countries = JSON.parse(element.getAttribute('data-countries'))
  const countrySelect = document.getElementById('country-select')

  countrySelect.addEventListener('change', () => {
    const subdivisionSelect = document.getElementById('subdivision-select')
    const selectedCountry = countrySelect.value
    subdivisionSelect.options.length = 0
    createOption('地域を選択してください', '', subdivisionSelect)

    countries[selectedCountry].forEach(subdivision => {
      createOption(subdivision[0], subdivision[1], subdivisionSelect)
    })
  })

  function createOption(text, value, element) {
    const option = document.createElement('option')
    option.text = text
    option.value = value
    element.appendChild(option)
  }
})
