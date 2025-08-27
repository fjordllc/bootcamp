import checkStamp from 'check-stamp.js'
import { FetchRequest } from '@rails/request.js'

export default {
  computed: {
    isUnassignedAndUncheckedProduct() {
      return (
        this.commentableType === 'Product' &&
        this.productCheckerId === null &&
        this.checkId === null
      )
    }
  },
  methods: {
    check(checkableType, checkableId, url, method) {
      const params = {
        checkable_type: checkableType,
        checkable_id: checkableId
      }
      new FetchRequest(method, url, {
        redirect: 'manual',
        body: JSON.stringify(params)
      })
        .perform()
        .then((response) => {
          if (!response.ok) {
            // return response.json()
            return response.json
          } else {
            return response
          }
        })
        .then((json) => {
          if (json.message) {
            this.toast(json.message, 'error')
          } else {
            checkStamp()
            if (!this.checkId) {
              const event = new Event('checked')
              document.dispatchEvent(event)
              if (checkableType === 'Product') {
                this.toast('提出物を合格にしました。')
              } else if (checkableType === 'Report') {
                this.toast('日報を確認済みにしました。')
              }
            } else {
              const event = new Event('unchecked')
              document.dispatchEvent(event)
            }
          }
        })
        .catch((error) => {
          console.warn(error)
        })
    },
    checkProduct(productId, currentUserId, url, method, isChargeFromComment) {
      const params = {
        product_id: productId,
        current_user_id: currentUserId
      }

      new FetchRequest(method, url, {
        redirect: 'manual',
        body: JSON.stringify(params)
      })
        .perform()
        .then((response) => {
          return response.json
        })
        .then((json) => {
          if (json.message) {
            alert(json.message)
          } else {
            this.id = json.checker_id
            this.name = json.checker_name
            if (this.id !== null) {
              if (isChargeFromComment) {
                alert('提出物の担当になりました。') // 担当が決まっていない提出物にメンターがコメントをした場合にアラートを出す
              }
              this.toast('担当になりました。')
            } else {
              this.toast('担当から外れました。')
            }
          }
        })
        .catch((error) => {
          console.warn(error)
        })
    }
  }
}
