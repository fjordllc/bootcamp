import Vue from 'vue'
import Vuex from 'vuex'

Vue.use(Vuex)

export default new Vuex.Store({
  state: {
    checkId: null,
    userName: null,
    craetedAt: null
  },
  getters: {
    checkId: state => state.checkId,
    userName: state => state.userName,
    createdAt: state => state.createdAt
  },
  mutations: {
    setCheckable (state, { checkId, userName, createdAt }) {
      state.checkId = checkId
      state.userName = userName
      state.createdAt = createdAt
    }
  },
  actions: {
    setCheckable ({ commit }, { checkableId, checkableType }) {
      const meta = document.querySelector('meta[name="csrf-token"]')
      fetch(`/api/checks.json/?${checkableType}_id=${checkableId}.json`, {
        method: 'GET',
        headers: {
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': meta ? meta.getAttribute('content') : ''
        },
        credentials: 'same-origin'
      })
        .then(response => {
          return response.json()
        })
        .then(json => {
          if (json[0]) {
            commit('setCheckable', {
              checkId: json[0]['id'],
              createdAt: json[0]['created_at']['to_date'],
              userName: json[0]['user']['login_name']
            })
          } else {
            commit('setCheckable', {
              checkId: null,
              createdAt: null,
              userName: null
            })
          }
        })
        .catch(error => {
          console.warn('Failed to parsing', error)
        })
    }
  }
})
