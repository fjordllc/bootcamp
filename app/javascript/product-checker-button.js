import CSRF from 'csrf'

const productChecker = {
  productChecker(productId, currentUserId, productCheckerId) {
    const token = CSRF.getToken()
    const url = '/api/products/checker'
    const method = productCheckerId ? 'DELETE' : 'PATCH'
    // const target = document.getElementById('change-checker-button')
    // console.log(event)
    // console.log(event.target)
    // console.log(event.target.className)
    // console.log(event.target.textContent)
    // console.log('target')
    // console.log(event.target)
    // console.log('currentTarget')
    // console.log(event.currentTarget.className)
    console.log(event.currentTarget.children[0].className)
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
      .catch((error) => {
        console.warn(error)
      })
  }
}
window.productChecker = productChecker
// document.addEventListener('DOMContentLoaded', () => {
//   const productCheckerButtons =
//     document.getElementsByClassName('product-checker')
//   productCheckerButtons[0].onclick = productChecker
//   productCheckerButtons[1].onclick = productChecker
// })

// import CSRF from 'csrf'
// import Checkable from 'checkable'

// document.addEventListener('DOMContentLoaded', () => {
//   const checkerButton = document.getElementById('product-checker')
//   checkerButton.addEventListener('click', () => {
//     const token = CSRF.getToken()
//     const params = {
//       product_id: productId,
//       current_user_id: currentUserId
//     }
//
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
//   })
// })
