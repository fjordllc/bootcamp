import ProductChecker from './product_checker.js'

document.addEventListener('DOMContentLoaded', () => {
  const buttons = document.querySelectorAll('.check-product-button')
  buttons.forEach((button) => {
    button.addEventListener('click', () => {
      const productId = button.getAttribute('data-product-id')
      const currentUserId = button.getAttribute('data-current-user-id')
      const url = button.getAttribute('data-url')
      const method = button.getAttribute('data-method')
      const token = button.getAttribute('data-token')

      const checker = new ProductChecker(
        productId,
        currentUserId,
        url,
        method,
        token
      )
      checker.checkProduct(button)
    })
  })
})
