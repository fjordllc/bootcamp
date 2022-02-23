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
        .then(() => {
          this.$store.dispatch('setCheckable', {
            checkableId: checkableId,
            checkableType: checkableType
          })
        })
        .catch((error) => {
          console.warn(error)
        })
    }
  }
}
