export default function validateTagName(tagData) {
  const text = tagData.value
  if (/\s/.test(text)) {
    return 'スペースを含むタグは作成できません'
  } else if (text === '.') {
    return 'ドット1つだけのタグは作成できません'
  } else if (/^(#|＃|♯)/.test(text)) {
    return '#を先頭に含むタグは作成できません'
  }
  return true
}
