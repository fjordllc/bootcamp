import { ProductChecker } from './product-checker.js'

document.addEventListener('turbo:load', initProductCheckers)
document.addEventListener('DOMContentLoaded', initProductCheckers)
initProductCheckers()

function initProductCheckers() {
  document.querySelectorAll('.card-list-item__assignee').forEach((el) => {
    // Skip if already initialized
    if (el.dataset.initialized) return

    new ProductChecker(el).initProductChecker()
    el.dataset.initialized = 'true'
  })
}
