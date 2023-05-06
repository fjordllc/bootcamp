const state = { books: [] }

const getters = {
      books: state => {
      return state.books
    }
}

const mutations = {
      setBooks(state, books) {
      books.forEach(book => {
        state.books.push(book)
      })
    }
}

const actions = {
    async getAllBooks({commit}) {
      const books = await getBooksAPI()
      commit('setBooks', books)
    }
}

function token() {
  const meta = document.querySelector('meta[name="csrf-token"]')
  return meta ? meta.getAttribute('content') : ''
}

async function getBooksAPI() {
  const url = '/api/books.json'
  const res = await fetch(url, {
    method: 'GET',
    headers: {
      'Content-Type': 'application/json; charset=utf-8',
      'X-Requested-With': 'XMLHttpRequest',
      'X-CSRF-Token': token()
    },
    credentials: 'same-origin',
    redirect: 'manual'
  })
  const data = await res.json()
  const books = data.books
  return books
}

export default {
  namespaced: true,
  state,
  getters,
  actions,
  mutations
}
