import Token from 'token'
import dayjs from 'dayjs'
import ja from 'dayjs/locale/ja'
dayjs.locale(ja)

const headers = () => {
  return {
    'Content-Type': 'application/json; charset=utf-8',
    'X-Requested-With': 'XMLHttpRequest',
    'X-CSRF-Token': Token.getToken()
  }
}

export default {
  patch(path, params = {}) {
    return fetch(path, {
      method: 'PATCH',
      headers: headers(),
      credentials: 'same-origin',
      redirect: 'manual',
      body: JSON.stringify(params)
    })
  },

  delete(path) {
    return fetch(path, {
      method: 'DELETE',
      headers: headers(),
      credentials: 'same-origin',
      redirect: 'manual'
    }).catch((error) => {
      console.warn(error)
    })
  },

  iso8601ToFullTime(isoString) {
    return dayjs(isoString).format('YYYY年MM月DD日(dd) HH:mm')
  }
}
