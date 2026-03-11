import { ProductChecker } from './product-checker.js'

document.addEventListener('DOMContentLoaded', () => {
  initProductCheckers()
})

// Turbolinks/Turbo 対応
document.addEventListener('turbolinks:load', () => {
  initProductCheckers()
})

document.addEventListener('turbo:load', () => {
  initProductCheckers()
})

function initProductCheckers() {
  document.querySelectorAll('.card-list-item__assignee').forEach((el) => {
    // 既に初期化済みの場合はスキップ
    if (el.dataset.initialized) return

    new ProductChecker(el).initProductChecker()
    el.dataset.initialized = 'true'
  })
}
