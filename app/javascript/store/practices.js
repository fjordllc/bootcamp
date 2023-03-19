import Vue from 'vue'
import Vuex from 'vuex'

Vue.use(Vuex)

const store = new Vuex.Store({
  state: {
    practices: [
      {
        category: '',
        id: 'null',
        title: 'すべての書籍を表示'
      }
    ]
  },
  getters: {
    practices: state => {
      return state.practices
    }
  },
  mutations: {
    setPractices(state, practices) {
      practices.forEach(practice => {
        state.practices.push(practice)
      })
    }
  },
  actions: {
    async getAllPractices({commit}) {
      const practices = await getPracticesAPI()
      commit('setPractices', practices)
    }
  }
})

function token() {
  const meta = document.querySelector('meta[name="csrf-token"]')
  return meta ? meta.getAttribute('content') : ''
}

async function getPracticesAPI() {
  const url = '/api/practices.json'
  const res = await fetch(url, {
    method: 'GET',
    headers: {
      'content-type': 'application/json; charset=utf-8',
      'X-Requested-With': 'XMLHttpRequest',
      'X-CSRF-Token': token()
    },
    credentials: 'same-origin',
    redirect: 'manual'
  })
  const data = await res.json()
  const practices = []
  data.forEach(item => {
    practices.push(item)
  })
  return practices
}

export default store
