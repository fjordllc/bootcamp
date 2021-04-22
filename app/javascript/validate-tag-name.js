export default {
  methods: {
    validateTagName(obj) {
      const { text } = obj.tag
      // eslint-disable-next-line no-irregular-whitespace
      if (/ |　/.test(text)) {
        alert('入力されたタグにスペースが含まれています') // eslint-disable-line no-undef
      } else if (text === '.') {
        alert('ドット1つだけのタグは作成できません') // eslint-disable-line no-undef
      } else {
        obj.addTag()
      }
    }
  }
}
