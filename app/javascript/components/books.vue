<template lang="pug">
.books
  .books__items
    .row(v-if='books === null')
      .empty
        .fa-solid.fa-spinner.fa-pulse
        |
        | ロード中
    .row(v-else-if='books.length !== 0')
      book(
        v-for='book in books',
        :key='book.id',
        :book='book',
        :currentUser='currentUser'
      )
    .row(v-else)
      .o-empty-message
        .o-empty-message__icon
          i.fa-regular.fa-sad-tear
        p.o-empty-message__text
          | 登録されている本はありません
</template>
<script>
import Book from './book'

export default {
  name: 'Books',
  components: {
    book: Book
  },
  data() {
    return {
      books: null,
      currentUser: null
    }
  },
  created() {
    window.onpopstate = function () {
      location.replace(location.href)
    }
    this.getBooks()
  },
  methods: {
    token() {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
    getBooks() {
      fetch('/api/books', {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': this.token()
        },
        credentials: 'same-origin',
        redirect: 'manual'
      })
        .then((response) => {
          return response.json()
        })
        .then((json) => {
          this.books = json.books
          this.currentUser = json.currentUser
        })
        .catch((error) => {
          console.warn(error)
        })
    }
  }
}
</script>
