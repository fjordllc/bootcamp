import CSRF from 'csrf'

const SearchUser = {
  controller: null,
  timeoutId: null,

  validateSearchUsersWord(searchUsersWord) {
    if (searchUsersWord.match(/^[\w-]+$/)) return searchUsersWord.length >= 3
    return searchUsersWord.length >= 2
  },
  addParams(searchUsersWord) {
    if (!SearchUser.validateSearchUsersWord(searchUsersWord)) return
    const params = new URL(location.origin).searchParams
    params.set('search_word', searchUsersWord)
    return params
  },

  url(searchUsersWord) {
    const params = SearchUser.getParams()
    const currentPage = Number(this.getParams().page) || 1
    const searchWordParams = SearchUser.addParams(searchUsersWord)
    return (
      '/api/users/' +
      (params.tag ? `tags/${params.tag}` : '') +
      `?page=${currentPage}` +
      (params.target ? `&target=${params.target}` : '') +
      (params.watch ? `&watch=${params.watch}` : '') +
      '&require_html=true' +
      (searchWordParams ? `&${searchWordParams}` : '')
    )
  },
  getParams() {
    const params = {}
    location.search
      .slice(1)
      .split('&')
      .forEach((query) => {
        const queryArr = query.split('=')
        params[queryArr[0]] = queryArr[1]
      })
    if (location.pathname.match(/tags/)) {
      const tag = location.pathname.split('/').pop()
      params.tag = tag
    }
    return params
  },

  async fetchUsersResource(searchUsersWord) {
    if (this.controller) {
      this.controller.abort()
    }

    this.controller = new AbortController()

    const usersResource = await fetch(SearchUser.url(searchUsersWord), {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': CSRF.getToken()
      },
      credentials: 'same-origin',
      redirect: 'manual',
      signal: this.controller.signal
    })
    return usersResource.json()
  },
  setupSearchedUsers(searchUsersWord) {
    clearTimeout(this.timeoutId)

    this.timeoutId = setTimeout(() => {
      SearchUser.fetchUsersResource(searchUsersWord)
        .then((response) => {
          document.getElementById(`user_lists`).innerHTML = response.html
          SearchUser.fixPaginationLinks()
        })
        .catch((error) => {
          if (error.name === 'AbortError') {
            // 非同期通信がキャンセルされた場合は何もしない
          } else {
            console.warn(error)
          }
        })
    }, 300)
  },
  fixPaginationLinks() {
    const paginationLinks = document.querySelectorAll('.pagination a')
    paginationLinks.forEach((link) => {
      link.href = link.href.replace('/api/users', '/users')
    })
  }
}

document.addEventListener('DOMContentLoaded', () => {
  const inputElement = document.getElementById('js-user-search-input')

  if (inputElement) {
    inputElement.addEventListener('input', function () {
      const inputValue = this.value.trim()
      SearchUser.setupSearchedUsers(inputValue)
    })
  }
})
