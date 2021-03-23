export default {
  methods: {
    validateTagName (obj) {
      const { text } = obj.tag
      if (/ |　/.test(text)) { // eslint-disable-line no-irregular-whitespace
        alert('入力されたタグにスペースが含まれています') // eslint-disable-line no-undef
      } else if (text === '.') {
        alert('ドット1つだけのタグは作成できません') // eslint-disable-line no-undef
      } else {
        obj.addTag()
      }
    }
  }
}
