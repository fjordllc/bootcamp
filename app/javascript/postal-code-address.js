document.addEventListener('DOMContentLoaded', () => {
  const zip1Element = document.getElementById('grant_course_application_zip1')
  const zip2Element = document.getElementById('grant_course_application_zip2')

  if (!zip1Element || !zip2Element) return

  const prefectureElement = document.getElementById(
    'grant_course_application_prefecture_code'
  )
  const address1Element = document.getElementById(
    'grant_course_application_address1'
  )

  const fetchAddress = () => {
    const zip1 = zip1Element.value
    const zip2 = zip2Element.value

    if (zip1.length === 3 && zip2.length === 4) {
      const postalCode = `${zip1}${zip2}`

      // Use Japan Post API to get address data
      fetch(`https://zipcloud.ibsnet.co.jp/api/search?zipcode=${postalCode}`)
        .then((response) => response.json())
        .then((data) => {
          if (data.results && data.results.length > 0) {
            const result = data.results[0]

            // Set prefecture code
            if (prefectureElement) {
              prefectureElement.value = result.prefcode
            }

            // Set city and town
            if (address1Element) {
              address1Element.value = `${result.address2}${result.address3}`
            }
          }
        })
        .catch((error) => {
          console.error('Postal code search error:', error)
        })
    }
  }

  zip1Element.addEventListener('input', () => {
    if (zip1Element.value.length === 3) {
      zip2Element.focus()
    }
  })

  zip2Element.addEventListener('input', fetchAddress)
  zip2Element.addEventListener('blur', fetchAddress)
})
