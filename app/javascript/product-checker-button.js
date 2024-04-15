import CSRF from 'csrf'

document.addEventListener('DOMContentLoaded', () => {
  const checkerButton = document.getElementById('product-checker')
  checkerButton.addEventListener('click', () => {
    const token = CSRF.getToken()
    console.log(`トークンです：${token}`)
  })
})
