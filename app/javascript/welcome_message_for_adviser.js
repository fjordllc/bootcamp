document.addEventListener('DOMContentLoaded', () => {
  if (document.cookie
    .split('; ')
    .find((row) => row.startsWith('confirmed_welcome_message')) === undefined
  ) {
    const selector = '.js-close-welcome-message'
    const button = document.querySelector(selector)

    button.addEventListener('click', () => {
      document.querySelector('.welcome_message_columns_for_adviser').remove()
      saveCookie()
    })
  } else {
    saveCookie()
  }

  function saveCookie() {
    const secondsFor30days = 2592000
    document.cookie =
      'confirmed_welcome_message=' +
      'confirmed_welcome_message' +
      ';max-age=' +
      secondsFor30days
  }
})
