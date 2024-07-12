document.addEventListener('DOMContentLoaded', function () {
  const checkBox = document.getElementsByName('credit_card_payment')
  const paymentMethods = document.getElementById('payment-methods')
  console.log(checkBox[0])
  checkBox[0].addEventListener('click', function () {
    console.log(checkBox[0].checked)
    if (checkBox[0].checked) {
      const div = document.createElement('div')
      div.id = 'foo'
      div.textContent = 'hoge'
      paymentMethods.appendChild(div)
    } else {
      const foo = document.getElementById('foo')
      paymentMethods.removeChild(foo)
    }
  })
})
