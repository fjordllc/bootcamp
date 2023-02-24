<template lang="pug">
.books
  .hoge
    countertest
  .filter-form
    filterselect(v-for='practice in practices' :practice='practice' :key='practice.index')
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
        :isMentor='isMentor')
  .o-empty-message(v-else)
    .o-empty-message__icon
      i.fa-regular.fa-sad-tear
    p.o-empty-message__text
      | 登録されている本はありません
</template>
<script>
import Vuex from 'vuex'
import CounterTest from './counter'
import FilterSelect from './filter-by-practices'
import Book from './book'

const store = new Vuex.Store({
  state: {
    count: 0
  },
  mutations: {
    increment (state) {
      state.count++
    }
  },
  actions: {
    increment ({ commit }) {
      commit('increment')
    },
  }
})

export default {
  name: 'Books',
  components: {
    countertest: CounterTest,
    filterselect: FilterSelect, 
    book: Book
  },
  store,
  props: {
    isAdmin: { type: Boolean, required: true },
    isMentor: { type: Boolean, required: true },
    practiceId: { type: Number, default: null, required: false }
  },
  data() {
    return {
      practices: [],
      books: null
    }
  },
  computed: {
    newParams() {
      const params = new URL(location.href).searchParams
      if (this.practiceId) params.set('practice_id', this.practiceId)
      return params
    },
    booksAPI() {
      const params = this.newParams
      return `/api/books.json?${params}`
    }
  },
  created() {
    window.onpopstate = function () {
      location.replace(location.href)
    }
    this.getBooks()
    this.getPractices()
  },
  methods: {
    token() {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
    getPractices() {
      fetch('/api/practices.json')
        .then((response) => {
          return response.json()
        })
        .then((json) =>{
          this.practices = json
        })
        .catch((error) => {
          console.warn(error)
        })
    },
    getBooks() {
      fetch(this.booksAPI, {
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
          this.books = []
          json.books.forEach((r) => {
            this.books.push(r)
          })
        })
        .catch((error) => {
          console.warn(error)
        })
    }
  }
}
</script>
