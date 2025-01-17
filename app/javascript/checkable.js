import { setCheckStamp } from 'check-stamp.js'

export default {
  computed: {
    isUnassignedAndUnchekedProduct() {
      return (
        this.commentableType === 'Product' &&
        this.productCheckerId === null &&
        this.checkId === null
      )
    }
  },
  methods: {
    check(checkableType, checkableId, url, method, token) {
      const params = {
        checkable_type: checkableType,
        checkable_id: checkableId
      }

      fetch(url, {
        method: method,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': token
        },
        credentials: 'same-origin',
        redirect: 'manual',
        body: JSON.stringify(params)
      })
        .then((response) => {
          this.$store.dispatch('setCheckable', {
            checkableId: checkableId,
            checkableType: checkableType
          })
          if (!response.ok) {
            return response.json()
          } else {
            return response
          }
        })
        .then((json) => {
          if (json.message) {
            this.toast(json.message, 'error')
          } else {
            setCheckStamp()
            if (!this.checkId) {
              if (checkableType === 'Product') {
                this.toast('提出物を確認済みにしました。')
              } else if (checkableType === 'Report') {
                this.toast('日報を確認済みにしました。')
              }
            }
          }
        })
        .catch((error) => {
          console.warn(error)
        })
    },
    checkProduct(
      productId,
      currentUserId,
      url,
      method,
      token,
      isChargeFromComment
    ) {
      const params = {
        product_id: productId,
        current_user_id: currentUserId
      }

      fetch(url, {
        method: method,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': token
        },
        credentials: 'same-origin',
        redirect: 'manual',
        body: JSON.stringify(params)
      })
        .then((response) => {
          return response.json()
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
            this.$store.dispatch('setProduct', {
              productId: productId
            })
          }
        })
        .catch((error) => {
          console.warn(error)
        })
    }
  }
}
