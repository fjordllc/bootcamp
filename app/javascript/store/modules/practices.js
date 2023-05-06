const state = {
  practices: [
    {
      category: '',
      id: 'null',
      title: 'すべての書籍を表示'
    }
  ]
}

const getters = {
  practices: state => {
    return state.practices
  }
}

const actions = {
  async getAllPractices({commit}) {
    const practices = await getPracticesAPI()
    commit('setPractices', practices)
  }
}

const mutations = {
  setPractices(state, practices) {
    practices.forEach(practice => {
      state.practices.push(practice)
    })
  }
}

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

export default {
  namespaced: true,
  state,
  getters,
  actions,
  mutations
}
// export default store
