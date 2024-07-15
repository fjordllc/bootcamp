document.addEventListener('DOMContentLoaded', function () {
  const checkBox = document.getElementsByName('credit_card_payment')
  const cardForm = document.getElementById('card')
  if (cardForm) {
    checkBox[0].addEventListener('click', function () {
      if (checkBox[0].checked) {
        cardForm.classList.remove('hidden')
      } else {
        cardForm.classList.add('hidden')
      }
    })
  }
})
