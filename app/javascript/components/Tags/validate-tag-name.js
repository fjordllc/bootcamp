export default function validateTagName(text) {
  if (/\s+/.test(text.value)) {
    return 'スペースを含むタグは作成できません'
  } else if (text.value === '.') {
    return 'ドット1つだけのタグは作成できません'
  } else if (/^(#|＃|♯)/.test(text.value)) {
    return '#を先頭に含むタグは作成できません'
  } else {
    return true
  }
}
