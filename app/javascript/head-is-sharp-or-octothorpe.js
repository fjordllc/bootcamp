export default {
  methods: {
    headIsSharpOrOctothorpe(text) {
      const regex = /^(#|＃|♯).*/
      return regex.test(text)
    }
  }
}
