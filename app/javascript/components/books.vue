<template lang="pug">
.books
  .empty(v-if='books === null')
    .fa-solid.fa-spinner.fa-pulse
    |
    | ロード中
  .books__items(v-else-if='books.length !== 0')
    .row
      book(
        v-for='book in books',
        :key='book.id',
        :book='book',
        :isAdmin='isAdmin',
        :isMentor='isMentor'
      )
  .o-empty-message(v-else)
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
  props: {
    isAdmin: { type: Boolean, required: true },
    isMentor: { type: Boolean, required: true }
  },
  data() {
    return {
      books: null,
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
        })
        .catch((error) => {
          console.warn(error)
        })
    }
  }
}
</script>
