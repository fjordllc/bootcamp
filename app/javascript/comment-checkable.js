import CSRF from 'csrf'
import { toast } from './vanillaToast.js'
import checkStamp from 'check-stamp.js'

async function sendRequest(url, method = 'GET', body = null) {
  const options = {
    method,
    headers: {
      'Content-Type': 'application/json; charset=utf-8',
      'X-Requested-With': 'XMLHttpRequest',
      'X-CSRF-Token': CSRF.getToken()
    },
    credentials: 'same-origin',
    redirect: 'manual'
  }
  if (body) {
    options.body = JSON.stringify(body)
  }

  const response = await fetch(url, options)

  let data
  if (response.ok) {
    try {
      data = await response.json()
    } catch {
      data = response
    }
  } else {
    try {
      data = await response.json()
    } catch {
      throw new Error(`HTTP error! status: ${response.status}`)
    }
  }

  return data
}

export default {
  async isUnassignedAndUncheckedProduct(checkableType, checkableId, isMentor) {
    if (!isMentor) return
    if (checkableType === 'Product') {
      const hasCheckerResult = await this.hasChecker(checkableId)
      const isCheckedResult = await this.isChecked(checkableType, checkableId)
      return hasCheckerResult === false && isCheckedResult === false
    }
  },

  async check(checkableType, checkableId, url, method) {
    const params = {
      checkable_type: checkableType,
      checkable_id: checkableId
    }

    try {
      const data = await sendRequest(url, method, params)

      if (data.message) {
        toast(data.message, 'error')
      } else {
        checkStamp()
      }
    } catch (error) {
      console.warn(error)
    }
  },

  async assignChecker(productId, currentUserId) {
    const params = {
      product_id: productId,
      current_user_id: currentUserId
    }

    try {
      const json = await sendRequest('/api/products/checker', 'PATCH', params)

      if (json.message) {
        alert(json.message)
      } else {
        alert('提出物の担当になりました。')

        const event = new Event('checkerAssigned')
        window.dispatchEvent(event)
      }
    } catch (error) {
      console.warn(error)
    }
  },

  async isChecked(checkableType, checkableId) {
    try {
      const json = await sendRequest(
        `/api/checks.json/?checkable_type=${checkableType}&checkable_id=${checkableId}`
      )
      return !!json[0]
    } catch (error) {
      console.warn(error)
    }
  },

  async hasChecker(productId) {
    try {
      const json = await sendRequest(
        `/api/products/checker.json?product_id=${productId}`
      )
      return !!json.checker_name
    } catch (error) {
      console.warn(error)
    }
  }
}
