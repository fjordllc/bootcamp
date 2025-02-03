<template lang="pug">
.page-body
  .page-content.is-books
    .container
      .books
        .empty(v-if='books === null')
          .fa-solid.fa-spinner.fa-pulse
          |
          | ロード中
        .books__items(v-else-if='books.length !== 0')
          .row
            book(
              v-for='book in filteredBooks',
              :key='book.id',
              :book='book',
              :isAdmin='isAdmin',
              :isMentor='isMentor')
        .a-empty-message(v-else)
          .a-empty-message__icon
            i.fa-regular.fa-sad-tear
          p.a-empty-message__text
            | 登録されている本はありません
</template>
<script>
import CSRF from 'csrf'
import Book from './book'

export default {
  name: 'CourseBooks',
  components: {
    book: Book
  },
  props: {
    isAdmin: { type: Boolean, required: true },
    isMentor: { type: Boolean, required: true },
    course: { type: Object, required: true }
  },
  data() {
    return {
      books: null,
      practices: []
    }
  },
  computed: {
    filteredBooks() {
      return this.books.filter((book) =>
        book.practices.some((practice) =>
          this.practices.some(
            (coursePractice) => coursePractice.id === practice.id
          )
        )
      )
    }
  },
  created() {
    this.getBooks()
    this.getPractices()
  },
  methods: {
    fetchGetData(url, callback) {
      const uri = `/api/${url}`
      fetch(uri, {
        method: 'GET',
        headers: {
          'content-type': 'application/json; charset=utf-8',
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': CSRF.getToken()
        },
        credentials: 'same-origin',
        redirect: 'manual'
      })
        .then((res) => res.json())
        .then(callback)
        .catch((err) => console.warn(err))
    },
    getBooks() {
      this.fetchGetData(`books.json`, (json) => {
        const urlParams = new URLSearchParams(window.location.search)
        const status = urlParams.get('status')
        if (status === 'mustread') {
          this.books = json.books.filter((book) => book.mustRead)
        } else {
          this.books = []
          json.books.forEach((book) => this.books.push(book))
        }
      })
    },
    getPractices() {
      this.fetchGetData(`courses/${this.course.id}/practices.json`, (json) => {
        json.categories.forEach((category) => {
          this.practices.push(
            ...category.practices.map(
              (categoryPractice) => categoryPractice.practice
            )
          )
        })
      })
    }
  }
}
</script>
