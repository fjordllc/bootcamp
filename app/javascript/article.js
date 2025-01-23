document.addEventListener('DOMContentLoaded', () => {
  const radioButtons = document.querySelectorAll(
    'input[name="article[target]"]'
  )
  if (radioButtons) {
    radioButtons.forEach((radio) => {
      radio.addEventListener('change', (event) => {
        const target = event.target.value
        const targetName = document
          .querySelector(`label[for="${radio.id}"]`)
          .textContent.trim()
        if (target !== 'none') {
          window.confirm(
            `この記事を公開すると、${targetName}に通知が送られます。もし記事に誤った情報が含まれている場合、その通知を受け取った人を介してSNSなどで拡散される可能性があります。そのため、記事内の年月日などに間違いがないか、しっかり確認してください。公開しても問題ありませんか？`
          )
        }
      })
    })
  }
})
