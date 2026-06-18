export default function validateTagName(tagData) {
  const text = tagData.value
  if (/ |\u3000/.test(text)) {
    return 'スペースを含むタグは作成できません'
  } else if (text === '.') {
    return 'ドット1つだけのタグは作成できません'
  }
  return true
}
