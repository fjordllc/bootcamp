export default function transformHeadSharp(text) {
  if (/^(#|＃|♯)/.test(text.value)) {
    text.value = text.value.substring(1)
  }
}
