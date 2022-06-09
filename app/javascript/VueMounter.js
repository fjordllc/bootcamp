import Vue from 'vue'

export default class VueMounter {
  mount() {
    document.addEventListener('DOMContentLoaded', () => {
      const elements = document.querySelectorAll('[data-vue]')
      if (elements.length > 0) {
        elements.forEach((element) => {
          const name = element.dataset.vue
          const props = this._convertProps(element.dataset)

          import(`./${name}.vue`).then((module) => {
            new Vue({
              render: (h) => h(module.default, { props: props })
            }).$mount(`[data-vue="${name}"]`)
          })
        })
      }
    })
  }

  _convertProps(props) {
    const objects = {}

    Object.keys(props)
      .filter((key) => key.match(/^vue.+/))
      .forEach((key) => {
        const rawKey = key.replace(/^vue/, '')
        const keyWithType = this._camelCase(rawKey)
        const matches = keyWithType.match(/:(.+)$/)

        const type = matches ? matches[1] : undefined
        const propKey = matches ? keyWithType.replace(/:.+$/, '') : keyWithType
        const value = matches ? this._parse(props[key], type) : props[key]

        objects[propKey] = value
      })
    return objects
  }

  _parse(value, type) {
    if (type === 'number') {
      return Number(value)
    } else if (type === 'boolean') {
      return Boolean(value)
    } else if (type === 'json') {
      return JSON.parse(value)
    } else if (type === 'string') {
      return String(value)
    } else {
      return value
    }
  }

  _camelCase(string) {
    string = string.charAt(0).toLowerCase() + string.slice(1)
    return string.replace(/[-_](.)/g, (_, group1) => {
      return group1.toUpperCase()
    })
  }
}
