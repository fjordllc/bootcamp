import Vue from 'vue'
import Vuex from 'vuex'
import CSRF from 'csrf'

Vue.use(Vuex)

export default new Vuex.Store({
  state: {
    checkId: null,
    checkableId: null,
    checkableType: null,
    productId: null,
    productCheckerId: null,
    watchId: null
  },
  getters: {
    checkId: (state) => state.checkId,
    checkableId: (state) => state.checkableId,
    checkableType: (state) => state.checkableType,
    productId: (state) => state.productId,
    productCheckerId: (state) => state.productCheckerId,
    watchId: (state) => state.watchId
  },
  mutations: {
    setCheckable(state, { checkId, checkableId, checkableType }) {
      state.checkId = checkId
      state.checkableId = checkableId
      state.checkableType = checkableType
    },
    setProduct(state, { productId, productCheckerId }) {
      state.productId = productId
      state.productCheckerId = productCheckerId
    },
    setWatchable(state, { watchId }) {
      state.watchId = watchId
    }
  },
  actions: {
    setCheckable({ commit }, { checkableId, checkableType }) {
      fetch(
        `/api/checks.json/?checkable_type=${checkableType}&checkable_id=${checkableId}`,
        {
          method: 'GET',
          headers: {
            'X-Requested-With': 'XMLHttpRequest',
            'X-CSRF-Token': CSRF.getToken()
          },
          credentials: 'same-origin'
        }
      )
        .then((response) => {
          return response.json()
        })
        .then((json) => {
          if (json[0]) {
            commit('setCheckable', {
              checkId: json[0].id,
              checkableId: checkableId,
              checkableType: checkableType
            })
          } else {
            commit('setCheckable', {
              checkId: null,
              checkableId: checkableId,
              checkableType: checkableType
            })
          }
        })
        .catch((error) => {
          console.warn(error)
        })
    },
    setProduct({ commit }, { productId }) {
      fetch(`/api/products/${productId}.json`, {
        method: 'GET',
        headers: {
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': CSRF.getToken()
        },
        credentials: 'same-origin'
      })
        .then((response) => {
          return response.json()
        })
        .then((product) => {
          if (product.checker_id !== null) {
            commit('setProduct', {
              productId: product.id,
              productCheckerId: product.checker_id
            })
          } else {
            commit('setProduct', {
              productId: productId,
              productCheckerId: null
            })
          }
        })
        .catch((error) => {
          console.warn(error)
        })
    },
    setWatchable({ commit }, { watchableId, watchableType }) {
      fetch(
        `/api/watches/toggle.json?watchable_id=${watchableId}&watchable_type=${watchableType}`,
        {
          method: 'GET',
          headers: {
            'X-Requested-With': 'XMLHttpRequest',
            'X-CSRF-Token': CSRF.getToken()
          },
          credentials: 'same-origin'
        }
      )
        .then((response) => {
          return response.json()
        })
        .then((watchable) => {
          if (watchable[0]) {
            commit('setWatchable', {
              watchId: watchable[0].id
            })
          } else {
            commit('setWatchable', {
              watchId: null
            })
          }
        })
        .catch((error) => {
          console.warn(error)
        })
    }
  }
})
