export default function headIsSharpOrOctothorpe(text) {
  const regex = /^(#|＃|♯).*/
  return regex.test(text)
}
