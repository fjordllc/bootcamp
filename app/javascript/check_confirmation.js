document.addEventListener('turbo:load', setupCheckConfirmation)
document.addEventListener('DOMContentLoaded', setupCheckConfirmation)

function setupCheckConfirmation() {
  const checkButton = document.querySelector('#js-shortcut-check')

  if (!checkButton) {
    return
  }

  const newCheckButton = checkButton.cloneNode(true)
  checkButton.parentNode.replaceChild(newCheckButton, checkButton)

  newCheckButton.addEventListener('click', (event) => {
    const hasNegativeEmotion = document.querySelector('#negative') !== null

    const commentCountElement = document.querySelector(
      'a[href="#comments"] > span'
    )
    let hasComment = false
    if (commentCountElement) {
      const numberOfComments = parseInt(commentCountElement.innerHTML, 10)
      hasComment = numberOfComments > 0
    }

    const isNewCheck = newCheckButton.dataset.hasCheck !== 'true'

    if (
      hasNegativeEmotion &&
      !hasComment &&
      isNewCheck &&
      !window.confirm(
        '今日の気分は「Negative」ですが、コメント無しで確認しますか？'
      )
    ) {
      event.preventDefault()
      return false
    }
  })
}
