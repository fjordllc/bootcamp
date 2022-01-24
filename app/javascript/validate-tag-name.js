export default {
  methods: {
    validateTagName(obj) {
      const { text } = obj.tag
      // eslint-disable-next-line no-irregular-whitespace
      if (/ |　/.test(text)) {
        alert('スペースを含むタグは作成できません') // eslint-disable-line no-undef
      } else if (text === '.') {
        alert('ドット1つだけのタグは作成できません') // eslint-disable-line no-undef
      } else {
        if (/^(#|＃|♯)/.test(text)) {
          if (text.length === 1) {
            return
          }
          obj.tag.text = text.substr(1)
        }
        obj.addTag()
      }
    }
  }
}
