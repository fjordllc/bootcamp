document.addEventListener('DOMContentLoaded', () => {
  const checkBox = document.querySelector('.selectable-credit-card-box')
  const cardForm = document.getElementById('card')
  if (cardForm && checkBox) {
    checkBox.addEventListener('click', () => {
      if (checkBox.checked) {
        cardForm.classList.remove('hidden')
      } else {
        cardForm.classList.add('hidden')
      }
    })
  }
})
