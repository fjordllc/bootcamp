import Vue from 'vue'
import Vuex from 'vuex'
import books from './modules/books'
import practices from './modules/practices'

Vue.use(Vuex)

export default new Vuex.Store({
  modules: {
    books,
    practices
  }
})
