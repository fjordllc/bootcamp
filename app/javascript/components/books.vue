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
import { mapGetters } from 'vuex'

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
      filterByPlacticeId: null
    }
  },
  computed: {
    ...mapGetters({
      books: 'books/books',
      practices: 'practices/practices'
    }),
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
    getBooks() {
      this.$store.dispatch('books/getAllBooks')
    },
    getPractices() {
      Promise.resolve(this.$store.dispatch("practices/getAllPractices"))
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
