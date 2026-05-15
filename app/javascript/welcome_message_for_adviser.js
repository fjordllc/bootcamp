document.addEventListener('DOMContentLoaded', () => {
  const welcomeMessageCookie = document.cookie
    .split('; ')
    .find((row) => row.startsWith('confirmed_welcome_message'))

  const selector = '.js-close-welcome-message'
  const button = document.querySelector(selector)

  if (welcomeMessageCookie === undefined) {
    if (!button) {
      return null
    }
    button.addEventListener('click', () => {
      document.querySelector('.js-welcome-message').remove()
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
      secondsFor30days +
      ';path=/'
  }
})
