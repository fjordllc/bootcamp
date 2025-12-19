import escapeHtml from 'escape-html'
import escapeStringRegexp from 'escape-string-regexp'
import emojis from 'markdown-it-emoji/lib/data/full.json'

export default class {
  constructor(menuItemsSize = 5) {
    this.menuItemsSize = menuItemsSize
  }

  params() {
    return {
      trigger: ':',
      fillAttr: 'key',
      requireLeadingSpace: true,
      values: (text, callback) => {
        this._filterValues(text, callback)
      },
      selectTemplate: (item) => {
        return item.original.value
      },
      menuItemTemplate: (item) => {
        if (item.original.isUser) {
          return (
            `<span class='mention'>${escapeHtml(
              item.original.login_name
            )}</span>` + `${escapeHtml(item.original.name)}`
          )
        } else {
          return (
            `${escapeHtml(item.original.value)}` +
            `<span class='emoji'>${escapeHtml(item.original.key)}</span>`
          )
        }
      }
    }
  }

  addUserData(json) {
    this.userValues = json.map((user) => {
      return {
        key: `@${user.login_name}`,
        value: `:@${user.login_name}:`,
        isUser: true,
        login_name: user.login_name,
        name: user.name
      }
    })
  }

  _fetchValues() {
    this.values = Object.keys(emojis)
      .map((key) => {
        return { key, value: emojis[key] }
      })
      .concat(this.userValues)
  }

  _filterValues(text, callback) {
    if (!this.values) {
      this._fetchValues()
    }

    if (text.length === 0) {
      return callback(this.values.slice(0, this.menuItemsSize))
    }

    const filteredValues = []
    const regex = new RegExp(escapeStringRegexp(text))

    this.values.every((value) => {
      if (value.key.match(regex)) {
        filteredValues.push(value)
      }

      return filteredValues.length < this.menuItemsSize
    })

    callback(filteredValues)
  }
}
