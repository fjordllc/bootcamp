import Vue from 'vue'
import store from './check-store.js'

export default class VueMounter {
  constructor() {
    this.components = {}
  }

  addComponent(component) {
    const name = component.name
    this.components[name] = component
  }

  mount() {
    document.addEventListener('DOMContentLoaded', () => {
      const elements = document.querySelectorAll('[data-vue]')
      if (elements.length > 0) {
        elements.forEach((element) => {
          const name = element.dataset.vue
          const props = this._convertProps(element.dataset)
          const component = this.components[name]

          new Vue({
            store,
            render: (h) => h(component, { props: props })
          }).$mount(`[data-vue="${name}"]`)
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
      const v = value.toLowerCase()
      if (v === 'false' || v === 'nil' || v === '') {
        return false
      } else {
        return true
      }
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
