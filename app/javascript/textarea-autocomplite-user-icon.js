import escapeHtml from 'escape-html'
import TextareaAutocomplteMention from './textarea-autocomplte-mention'

export default class extends TextareaAutocomplteMention {
  params() {
    return {
      trigger: ':@',
      fillAttr: 'login_name',
      requireLeadingSpace: true,
      selectTemplate: (item) => {
        console.log(item)
        return ':@' + item.original.login_name + ':'
      },
      values: (text, callback) => {
        this._filterValues(text, callback)
      },
      lookup: (person) => {
        return person.login_name + person.name
      },
      menuItemTemplate: (item) => {
        return (
          `<span class='mention'>${escapeHtml(
            item.original.login_name
          )}</span>` + `${escapeHtml(item.original.name)}`
        )
      }
    }
  }
}
