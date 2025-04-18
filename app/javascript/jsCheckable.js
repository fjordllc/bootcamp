import CSRF from 'csrf'
import { toast } from './vanillaToast.js'
import checkStamp from 'check-stamp.js'

export default {
  async isUnassignedAndUncheckedProduct(checkableType, checkableId) {
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
      const response = await fetch(url, {
        method: method,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': CSRF.getToken()
        },
        credentials: 'same-origin',
        redirect: 'manual',
        body: JSON.stringify(params)
      })

      let data
      if (response.ok) {
        data = response
      } else {
        data = await response.json()
      }

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
      const response = await fetch('/api/products/checker', {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': CSRF.getToken()
        },
        credentials: 'same-origin',
        redirect: 'manual',
        body: JSON.stringify(params)
      })

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }

      const json = await response.json()

      if (json.message) {
        alert(json.message)
      } else {
        alert('提出物の担当になりました。')

        const event = new CustomEvent('checkerAssigned')
        window.dispatchEvent(event)
      }
    } catch (error) {
      console.warn(error)
    }
  },

  async isChecked(checkableType, checkableId) {
    try {
      const response = await fetch(
        `/api/checks.json/?checkable_type=${checkableType}&checkable_id=${checkableId}`,
        {
          method: 'GET',
          headers: {
            'X-Requested-With': 'XMLHttpRequest',
            'X-CSRF-Token': CSRF.getToken()
          },
          credentials: 'same-origin'
        }
      )
      const json = await response.json()

      return !!json[0]

    } catch (error) {
      console.warn(error)
    }
  },

  async hasChecker(productId) {
    try {
      const response = await fetch(
        `/api/products/checker.json?product_id=${productId}`,
        {
          method: 'GET',
          headers: {
            'Content-Type': 'application/json; charset=utf-8',
            'X-Requested-With': 'XMLHttpRequest',
            'X-CSRF-Token': CSRF.getToken()
          },
          credentials: 'same-origin'
        }
      )
      const json = await response.json()

      return !!json.checker_name
      
    } catch (error) {
      console.warn(error)
    }
  }
}
