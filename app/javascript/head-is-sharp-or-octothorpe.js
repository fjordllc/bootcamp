export default function headIsSharpOrOctothorpe(text) {
  if (!text) {
    return false
  }
  return /^(#|＃|♯)/.test(text)
}
