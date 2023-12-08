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
  name: 'CourseBooks',
  components: {
    book: Book,
    filterDropdown: FilterDropdown
  },
  props: {
    isAdmin: { type: Boolean, required: true },
    isMentor: { type: Boolean, required: true },
    course: { type: Object, required: true }
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
        : this.books.filter((book) =>
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
    getBooks() {
      const uri = '/api/books.json'
      const urlParams = new URLSearchParams(window.location.search)
      const status = urlParams.get('status')
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
          if (status === 'mustread') {
            this.books = json.books.filter((book) => book.mustRead)
          } else {
            this.books = []
            json.books.forEach((book) => this.books.push(book))
          }
        })
        .catch((err) => console.warn(err))
    },
    getPractices() {
      const uri = `/api/courses/${this.course.id}/practices.json`
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
        .then((json) => {
          this.practices = [
            {
              id: null,
              title: '全プラクティスの参考書籍を表示'
            }
          ]
          json.categories.forEach((category) => {
            this.practices.push(
              ...category.practices.map(
                (categoryPractice) => categoryPractice.practice
              )
            )
          })
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
