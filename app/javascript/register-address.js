document.addEventListener('DOMContentLoaded', () => {
  const radioButtons = document.getElementsByName('register_address')

  if (!radioButtons) {
    return null
  }

  radioButtons.forEach((button) => {
    button.addEventListener('change', () => {
      const countryForm = document.getElementById('country-form')
      const subdivisionForm = document.getElementById('subdivision-form')
      const addressForms = [countryForm, subdivisionForm]

      addressForms.forEach((form) => {
        form.classList.toggle('is-hidden')
      })

      const value = document.querySelector(
        'input:checked[name=register_address]'
      ).value
      const countrySelect = document.getElementById('country-select')
      const subdivisionSelect = document.getElementById('subdivision-select')

      if (value === 'yes') {
        if (countrySelect.value === '') {
          countrySelect.querySelector("option[value='JP']").selected = true

          const countries = JSON.parse(
            countryForm.getAttribute('data-countries')
          )

          countries.JP.forEach((subdivision) => {
            const option = document.createElement('option')
            option.text = subdivision[0]
            option.value = subdivision[1]
            subdivisionSelect.appendChild(option)
          })
        }

        const inputs = document.querySelectorAll(
          "input[type=hidden][value='']"
        )

        if (inputs) {
          inputs.forEach((input) => {
            input.remove()
          })
        }
      } else {
        countrySelect.after(createInput('user[country_code]'))
        subdivisionSelect.after(createInput('user[subdivision_code]'))
      }
    })
  })

  function createInput(name) {
    const input = document.createElement('input')
    input.setAttribute('type', 'hidden')
    input.setAttribute('value', '')
    input.setAttribute('name', name)
    return input
  }
})
