import Vue from 'vue'
import productChecker from './product_checker.vue'

document.addEventListener('DOMContentLoaded', () => {
  const selector = '.js-checker'
  const checkers = document.querySelectorAll(selector)
  if (checkers) {
    for (let i = 0; i < checkers.length; i++) {
      const checker = checkers[i]
      const checkerId = checker.getAttribute('data-checker-id')
      const checkerName = checker.getAttribute('data-checker-name')
      const currentUserId = checker.getAttribute('data-current-user-id')
      const productId = checker.getAttribute('data-product-id')
      new Vue({
        render: h => h(productChecker, { props: {
          checkerId: checkerId,
          checkerName: checkerName,
          currentUserId: currentUserId,
          productId: productId
        } })
      }).$mount(selector)
    }
  }
})
