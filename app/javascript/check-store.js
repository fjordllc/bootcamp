import Vue from 'vue'
import Vuex from 'vuex'
import CSRF from 'csrf'

Vue.use(Vuex)

export default new Vuex.Store({
  state: {
    checkId: null,
    userName: null,
    createdAt: null,
    checkableId: null,
    checkableType: null,
    productId: null,
    productCheckerId: null,
    watchableUserId: null
  },
  getters: {
    checkId: (state) => state.checkId,
    userName: (state) => state.userName,
    createdAt: (state) => state.createdAt,
    checkableId: (state) => state.checkableId,
    checkableType: (state) => state.checkableType,
    productId: (state) => state.productId,
    productCheckerId: (state) => state.productCheckerId,
    watchableUserId: (state) => state.watchableUserId
  },
  mutations: {
    setCheckable(
      state,
      { checkId, userName, createdAt, checkableId, checkableType }
    ) {
      state.checkId = checkId
      state.userName = userName
      state.createdAt = createdAt
      state.checkableId = checkableId
      state.checkableType = checkableType
    },
    setProduct(state, { productId, productCheckerId }) {
      state.productId = productId
      state.productCheckerId = productCheckerId
    },
    setWatchable(state, { watchableUserId }) {
      state.watchableUserId = watchableUserId
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
              createdAt: json[0].created_at,
              userName: json[0].user.login_name,
              checkableId: checkableId,
              checkableType: checkableType
            })
          } else {
            commit('setCheckable', {
              checkId: null,
              createdAt: null,
              userName: null,
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
    setWatchable({ commit }, { watchableUserId }) {
      if (watchableUserId) {
        commit('setWatchable', {
          watchableUserId: watchableUserId
        })
      } else {
        commit('setWatchable', {
          watchableUserId: null
        })
      }
    }
  }
})
