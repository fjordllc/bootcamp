<template lang="pug">
.page-body
  nav.page-filter.form
    .container.is-md
      filterDropdown(
        label='プラクティスで絞り込む',
        :options='practices',
        v-model='practiceId')
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
import CSRF from 'csrf'
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
      practices: [],
      practiceId: null
    }
  },
  computed: {
    filteredBooks() {
      return this.practiceId
        ? this.books.filter((book) =>
            book.practices.some(
              (practice) => practice.id === Number(this.practiceId)
            )
          )
        : this.books
    }
  },
  created() {
    this.getBooks()
    this.getPractices()
  },
  methods: {
    getBooks() {
      const uri = '/api/books.json'
      fetch(uri, {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': CSRF.getToken()
        },
        credentials: 'same-origin',
        redirect: 'manual'
      })
        .then((res) => res.json())
        .then((json) => {
          this.books = []
          json.books.forEach((book) => this.books.push(book))
        })
        .catch((err) => console.warn(err))
    },
    getPractices() {
      const uri = '/api/users.json'
      fetch(uri, {
        method: 'GET',
        headers: {
          'content-type': 'application/json; charset=utf-8',
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': this.token()
        },
        credentials: 'same-origin',
        redirect: 'manual'
      })
        .then((res) => res.json())
        .then((json) => {
          this.practices = [
            {
              id: null,
              title: 'すべての参考書籍を表示'
            }
          ]
          json.currentUser.practices.forEach((practice) =>
            this.practices.push(practice)
          )
        })
        .then(() => this.choicesUi())
        .catch((err) => console.warn(err))
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
