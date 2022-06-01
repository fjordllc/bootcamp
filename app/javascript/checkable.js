export default {
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
          }
        })
        .catch((error) => {
          console.warn(error)
        })
    },
    checkProduct(productId, currentUserId, url, method, token) {
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
