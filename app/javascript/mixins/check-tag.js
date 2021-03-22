export default {
  methods: {
    checkTag (obj) {
      const { text } = obj.tag
      if (/ |　/.test(text)) {
        alert('入力されたタグにスペースが含まれています')
      } else if (text === '.') {
        alert('ドット1つだけのタグは作成できません')
      } else {
        obj.addTag()
      }
    }
  }
}
