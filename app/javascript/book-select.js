import Vue from 'vue'
import BookSelect from './book-select.vue'

document.addEventListener('DOMContentLoaded', () => {
  const selector = '.js-book-select'
  const hiddenSelector = '.reference-books-form-item input[name$="[book_id]"]'
  const hiddenSelectorAll = document.querySelectorAll(hiddenSelector)
  const bookSelectAll = document.querySelectorAll(selector)
  if (bookSelectAll) {
    for (let i = 0; i < bookSelectAll.length; i++) {
      const bookSelected = bookSelectAll[i].getAttribute('data-selected-book')
      const books = bookSelectAll[i].getAttribute('data-books')
      const hiddenNameParam = hiddenSelectorAll[i].getAttribute('name')
      new Vue({
        render: (h) =>
          h(BookSelect, {
            props: {
              bookSelected: bookSelected,
              books: books,
              hiddenNameParam: hiddenNameParam
            }
          })
      }).$mount(selector)
    }
  }
  $('.reference-books-form__add').on('cocoon:after-insert', () => {
    const selector = '.js-book-select'
    const hiddenSelector = '.reference-books-form-item input[name$="[book_id]"]'
    const hiddenSelectorAll = document.querySelectorAll(hiddenSelector)
    const bookSelectAll = document.querySelectorAll(selector)
    const hiddenSelectLast = hiddenSelectorAll[hiddenSelectorAll.length - 1]
    const bookSelectLast = bookSelectAll[bookSelectAll.length - 1]
    if (bookSelectLast) {
      const bookSelected = bookSelectLast.getAttribute('data-selected-book')
      const books = bookSelectLast.getAttribute('data-books')
      const hiddenNameParam = hiddenSelectLast.getAttribute('name')
      console.log(hiddenNameParam)
      new Vue({
        render: (h) =>
          h(BookSelect, {
            props: {
              bookSelected: bookSelected,
              books: books,
              hiddenNameParam: hiddenNameParam
            }
          })
      }).$mount(selector)
    }
  })
})
