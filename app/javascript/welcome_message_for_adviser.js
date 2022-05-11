document.addEventListener('DOMContentLoaded', () => {
  const welcomeMessageCookie = document.cookie
                                 .split('; ')
                                 .find((row) => row.startsWith('confirmed_welcome_message'))

  if (welcomeMessageCookie === undefined) {
    const selector = '.js-close-welcome-message'
    const button = document.querySelector(selector)

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
      ';path=/home'
  }
})
