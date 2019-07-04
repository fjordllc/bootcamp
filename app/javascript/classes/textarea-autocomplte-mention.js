import escapeHtml from 'escape-html'
import escapeStringRegexp from 'escape-string-regexp'

export default class {
  constructor (menuItemsSize = 5) {
    this.menuItemsSize = menuItemsSize
  }

  params () {
    return {
      trigger: '@',
      fillAttr: 'login_name',
      requireLeadingSpace: true,
      values: (text, callback) => {
        this._filterValues(text, callback)
      },
      lookup: (person, _mentionText) => {
        return person.login_name + person.last_name + person.first_name
      },
      menuItemTemplate: (item) => {
        return `<span class='mention'>${escapeHtml(item.original.login_name)}</span>` +
          `${escapeHtml(item.original.last_name)} ${escapeHtml(item.original.first_name)}`
      }
    }
  }

  fetchValues (callback) {
    fetch('/api/users', {
      method: 'GET',
      credentials: 'same-origin',
      headers: { 'X-Requested-With': 'XMLHttpRequest' }
    }).then(response => {
      return response.json()
    }).then(json => {
      callback(json)
    }).catch(error => {
      console.warn(error)
    })
  }

  _filterValues (text, callback) {
    if (text.length === 0) {
      return callback(this.values.slice(0, this.menuItemsSize))
    }

    let filteredValues = []
    const regex = new RegExp(escapeStringRegexp(text), 'i')

    this.values.every(value => {
      if ((value.login_name + value.first_name + value.last_name).match(regex)) {
        filteredValues.push(value)
      }
      return filteredValues.length < this.menuItemsSize
    })

    callback(filteredValues)
  }
}
