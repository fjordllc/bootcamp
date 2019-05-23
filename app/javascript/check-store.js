import Vue from 'vue'
import Vuex from 'vuex'

Vue.use(Vuex)

export default new Vuex.Store({
  state: {
    checkId: null,
    userName: null,
    craetedAt: null,
  },
  getters: {
    checkId: state => state.checkId,
    userName: state => state.userName,
    createdAt: state => state.createdAt
  },
  mutations: {
    setCheckable (state, {checkId, userName, createdAt}) {
      state.checkId = checkId
      state.userName = userName
      state.createdAt = createdAt
    }
  },
  actions: {
    setCheckable ({ commit }, {checkableId, checkableType }) {
      const meta = document.querySelector('meta[name="csrf-token"]')
      fetch(`/api/${checkableType}s/${checkableId}.json`, {
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
        commit('setCheckable', {
          checkId: json['check_id'],
          userName: json['user_name'],
          createdAt: json['created_at']
        });
      })
      .catch(error => {
        console.warn('Failed to parsing', error)
      })
    }
  }
})