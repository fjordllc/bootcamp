import Swal from 'sweetalert2'

export default class ProductChecker {
  constructor(productId, currentUserId, url, method, token) {
    this.productId = productId
    this.currentUserId = currentUserId
    this.url = url
    this.method = method
    this.token = token
  }

  toast(title, status = 'success') {
    Swal.fire({
      title: title,
      toast: true,
      position: 'top-end',
      showConfirmButton: false,
      timer: 3000,
      timerProgressBar: true,
      customClass: { popup: `is-${status}` }
    })
  }

  updateButton(button) {
    let buttonClass, buttonLabel, dataMethod, fasClass

    if (this.id !== null) {
      buttonClass = 'is-warning'
      buttonLabel = '担当から外れる'
      dataMethod = 'DELETE'
      fasClass = 'fa-times'
    } else {
      buttonClass = 'is-secondary'
      buttonLabel = '担当する'
      dataMethod = 'PATCH'
      fasClass = 'fa-hand-paper'
    }
    button.className = `a-button is-block is-sm ${buttonClass}`
    button.setAttribute('data-method', dataMethod)
    const icon = button.querySelector('i')
    icon.className = `fas ${fasClass}`
    icon.nextSibling.textContent = ` ${buttonLabel}`
  }

  checkProduct(button) {
    const params = {
      product_id: this.productId,
      current_user_id: this.currentUserId
    }

    fetch(this.url, {
      method: this.method,
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': this.token
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
          this.updateButton(button)
        }
      })
      .catch((error) => {
        console.warn(error)
      })
  }
}
