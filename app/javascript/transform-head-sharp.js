export default function transformHeadSharp(text) {
  if (/^(#|＃|♯)/.test(text.value)) {
    if (text.length === 1) {
      return
    }
    text.value = text.value.substr(1)
  }
}
