document.addEventListener('DOMContentLoaded', () => {
  const form = document.getElementById('article_form')
  if (!form) {
    return
  }
  const submitButtons = form.querySelectorAll(
    'input[type="submit"',
    'button[type="submit"]'
  )
  const publishButton = document.getElementById('js-shortcut-submit')
  let isPublish = false
  publishButton.addEventListener('click', () => {
    isPublish = true
  })

  const radioButtons = document.querySelectorAll(
    'input[name="article[target]"]'
  )
  const defaultTarget = document.querySelector(
    'input[name="article[target]"]:checked'
  )
  let target = defaultTarget.value
  let targetName = document
    .querySelector(`label[for="${defaultTarget.id}"]`)
    .textContent.trim()
  let alertText =
    target === 'none'
      ? '「通知しない」が選択されています。よろしいですか？'
      : `この記事を公開すると、${targetName}に通知が送られます。もし記事に誤った情報が含まれている場合、その通知を受け取った人を介してSNSなどで拡散される可能性があります。そのため、記事内の年月日などに間違いがないか、しっかり確認してください。公開しても問題ありませんか？`

  radioButtons.forEach((radio) => {
    radio.addEventListener('change', (event) => {
      target = event.target.value
      targetName = document
        .querySelector(`label[for="${radio.id}"]`)
        .textContent.trim()
      alertText =
        target === 'none'
          ? '「通知しない」が選択されています。よろしいですか？'
          : `この記事を公開すると、${targetName}に通知が送られます。もし記事に誤った情報が含まれている場合、その通知を受け取った人を介してSNSなどで拡散される可能性があります。そのため、記事内の年月日などに間違いがないか、しっかり確認してください。公開しても問題ありませんか？`
    })
  })

  form.addEventListener('submit', (event) => {
    if (isPublish) {
      submitButtons.forEach((button) => {
        button.removeAttribute('data-disable-with')
      })
      if (!window.confirm(alertText)) {
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
