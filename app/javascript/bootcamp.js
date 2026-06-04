import CSRF from 'csrf'
import { formatDateToJapanese } from './utilities/date.js'

const headers = () => {
  return {
    'Content-Type': 'application/json; charset=utf-8',
    'X-Requested-With': 'XMLHttpRequest',
    'X-CSRF-Token': CSRF.getToken()
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

  post(path, params = {}) {
    return fetch(path, {
      method: 'POST',
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
    return formatDateToJapanese(isoString)
  }
}
