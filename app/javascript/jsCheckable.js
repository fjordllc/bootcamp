import CSRF from 'csrf'
import { toast } from './vanillaToast.js'
import checkStamp from 'check-stamp.js'

export default {
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
        if (checkableType === 'Product') {
          toast('提出物を確認済みにしました。')
        } else if (checkableType === 'Report') {
          toast('日報を確認済みにしました。')
        }
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
      const json =  await response.json()

      if (json[0]) {
        return true;
      } else {
        return false;
      }
    } catch (error) {
      console.warn(error)
    }
  }
}
