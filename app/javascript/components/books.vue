<template lang="pug">
.page-body
  nav.page-filter.form
    .container.is-md
      filterDropdown(label='プラクティスで絞り込む' :options='practices' v-model='filterByPlacticeId')
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
        .o-empty-message(v-else)
          .o-empty-message__icon
            i.fa-regular.fa-sad-tear
          p.o-empty-message__text
            | 登録されている本はありません
</template>
<script>
import Choices from 'choices.js'
import Book from './book'
import FilterDropdown from './filterDropdown'

export default {
  name: 'Books',
  components: {
    book: Book,
    filterDropdown: FilterDropdown
  },
  props: {
    isAdmin: { type: Boolean, required: true },
    isMentor: { type: Boolean, required: true }
  },
  data() {
    return {
      books: null,
      filterByPlacticeId: null
    }
  },
  computed: {
    practices() {
      return this.$store.getters.practices
    },
    filteredBooks() {
      return this.filterByPlacticeId === null || this.filterByPlacticeId === "null"
        ? this.books
        : this.books.filter(book => book.practices.some(practice => practice.id === Number(this.filterByPlacticeId)))
    }
  },
  created() {
    this.getBooks()
    this.getPractices()
  },
  methods: {
    token() {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
    getBooks() {
      const url = '/api/books.json'
      fetch(url, {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': this.token()
        },
        credentials: 'same-origin',
        redirect: 'manual'
      })
        .then(res => res.json())
        .then(json => {
          this.books = []
          json.books.forEach(item => this.books.push(item))
        })
        .catch(error => console.warn(error))
    },
    getPractices() {
      Promise.resolve(this.$store.dispatch('getAllPractices'))
      .then(() => {this.choicesUi()})
    },
    choicesUi() {
      const element = document.querySelector('#js-choices-single-select')
      if (element) {
        return new Choices(element, {
          searchEnabled: true,
          allowHTML: true,
          searchResultLimit: 20,
          searchPlaceholderValue: '検索ワード',
          noResultsText: '一致する情報は見つかりません',
          itemSelectText: '選択',
          shouldSort: false
        })
      }
    }
  }
}
</script>
