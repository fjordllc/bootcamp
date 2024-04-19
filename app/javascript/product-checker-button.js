import CSRF from 'csrf'

const productChecker = {
  checkProduct(productId, currentUserId) {
    const token = CSRF.getToken()
    const url = '/api/products/checker'
    // console.log(method)
    // console.log(productId)
    // console.log(currentUserId)

    const params = {
      product_id: productId,
      current_user_id: currentUserId
    }

    const query = new URLSearchParams(params)
    // console.log(url + `?${query}`)
    fetch(url + `?${query}`, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': token
      },
      credentials: 'same-origin',
      redirect: 'manual'
    })
      .then((response) => {
        return response.json()
      })
      .then((json) => {
        return json.checker_id ? 'DELETE' : 'PATCH'
      })
      .then((method) => {
        console.log(method)
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
            console.log(json)
          })
        // .then((json) => {
        //   if (json.message) {
        //     alert(json.message)
        //   } else {
        //     this.id = json.checker_id
        //     this.name = json.checker_name
        //     if (this.id !== null) {
        //       this.toast('担当になりました。')
        //     } else {
        //       this.toast('担当から外れました。')
        //     }
        //     this.$store.dispatch('setProduct', {
        //       productId: productId
        //     })
        //   }
        // })
        // .catch((error) => {
        //   console.warn(error)
        // })
      })

    if (
      event.currentTarget.className ===
      'product-checker a-button is-block is-sm'
    ) {
      event.currentTarget.className =
        'product-checker a-button is-block is-warning is-sm'
      event.currentTarget.children[0].className = 'fas fa-times'
      event.currentTarget.children[0].textContent = '担当から外れる'
    } else {
      event.currentTarget.className = 'product-checker a-button is-block is-sm'
      event.currentTarget.children[0].className = 'fas fa-hand-paper'
      event.currentTarget.children[0].textContent = '担当する'
    }

    // 非同期関数checkerIdをAPIから取得
    // const myAsync = async (urlOfApi) => {
    //   const response = await fetch(urlOfApi, {
    //     method: 'GET',
    //     headers: {
    //       'Content-Type': 'application/json; charset=utf-8',
    //       'X-Requested-With': 'XMLHttpRequest',
    //       'X-CSRF-Token': token
    //     },
    //     credentials: 'same-origin',
    //     redirect: 'manual'
    //   })
    //   const json = response.json()
    //   const method1 = json.checker_id ? 'DELETE' : 'PATCH'
    //   return method1
    // }
    // const requestMethod = myAsync(url + `?${query}`)
    // console.log(requestMethod)
    // requestMethod.then((response) => {
    //   console.log(response)
    // })

    //     console.log(method)
    //     console.log(productId)
    //     if (
    //       event.currentTarget.className ===
    //       'product-checker a-button is-block is-sm'
    //     ) {
    //       event.currentTarget.className =
    //         'product-checker a-button is-block is-warning is-sm'
    //       event.currentTarget.children[0].className = 'fas fa-times'
    //       event.currentTarget.children[0].textContent = '担当から外れる'
    //     } else {
    //       event.currentTarget.className = 'product-checker a-button is-block is-sm'
    //       event.currentTarget.children[0].className = 'fas fa-hand-paper'
    //       event.currentTarget.children[0].textContent = '担当する'
    //     }
    //     const params = {
    //       product_id: productId,
    //       current_user_id: currentUserId
    //     }
    //     fetch(url, {
    //       method: method,
    //       headers: {
    //         'Content-Type': 'application/json; charset=utf-8',
    //         'X-Requested-With': 'XMLHttpRequest',
    //         'X-CSRF-Token': token
    //       },
    //       credentials: 'same-origin',
    //       redirect: 'manual',
    //       body: JSON.stringify(params)
    //     })
    //       .then((response) => {
    //         return response.json()
    //       })
    //       .then((json) => {
    //         console.log(json)
    //       })
    //       .then((json) => {
    //         if (json.message) {
    //           alert(json.message)
    //         } else {
    //           this.id = json.checker_id
    //           this.name = json.checker_name
    //           if (this.id !== null) {
    //             this.toast('担当になりました。')
    //           } else {
    //             this.toast('担当から外れました。')
    //           }
    //           this.$store.dispatch('setProduct', {
    //             productId: productId
    //           })
    //         }
    //       })
    //       .catch((error) => {
    //         console.warn(error)
    //       })
  }
}
window.productChecker = productChecker
