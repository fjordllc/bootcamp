export default function validateTagName(tagData) {
  const text = tagData.value
  if (/ |\u3000/.test(text)) {
    return 'スペースを含むタグは作成できません' // eslint-disable-line no-undef
  } else if (text === '.') {
    return 'ドット1つだけのタグは作成できません' // eslint-disable-line no-undef
  }
  return true
}
