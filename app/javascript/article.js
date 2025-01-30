document.addEventListener('DOMContentLoaded', () => {
  const radioButtons = document.querySelectorAll(
    'input[name="article[target]"]'
  )
  const defaultTarget = document.querySelector(
    'input[name="article[target]"]:checked'
  )
  if (!defaultTarget) {
    return
  }
  let target = defaultTarget.value
  let targetName = document
    .querySelector(`label[for="${defaultTarget.id}"]`)
    .textContent.trim()
  let text = setAlertText(target, targetName)

  radioButtons.forEach((radio) => {
    radio.addEventListener('change', (event) => {
      target = event.target.value
      targetName = document
        .querySelector(`label[for="${radio.id}"]`)
        .textContent.trim()
      text = setAlertText(target, targetName)
    })
  })

  const form = document.getElementById('article_form')
  const submitButtons = form.querySelectorAll(
    'input[type="submit"',
    'button[type="submit"]'
  )
  const publishButton = document.getElementById('js-shortcut-submit')
  let isPublish = false
  publishButton.addEventListener('click', () => {
    isPublish = true
  })

  form.addEventListener('submit', (event) => {
    if (isPublish) {
      submitButtons.forEach((button) => {
        button.removeAttribute('data-disable-with')
      })
      if (!window.confirm(text)) {
        event.preventDefault()
        isPublish = false
      } else {
        submitButtons.forEach((button) => {
          button.disabled = true
        })
      }
    }
  })
})

function setAlertText(target, targetName) {
  if (target === 'none') {
    return '「通知しない」が選択されています。よろしいですか？'
  } else {
    return `この記事を公開すると、${targetName}に通知が送られます。もし記事に誤った情報が含まれている場合、その通知を受け取った人を介してSNSなどで拡散される可能性があります。そのため、記事内の年月日などに間違いがないか、しっかり確認してください。公開しても問題ありませんか？`
  }
}
