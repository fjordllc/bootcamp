document.addEventListener('DOMContentLoaded', () => {
  const btn = document.getElementById('btn-generate-summary')
  const textarea = document.getElementById('summary-text-area')
  btn.addEventListener('click', async (e) => {
    e.preventDefault()
    try {
      btn.disabled = true
      btn.innerText = '生成中..'
      const articleBody = document.querySelector('[name="article[body]"]').value
      const response = await fetch('/articles/generate_summary', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector("meta[name='csrf-token']")
            .content
        },
        body: JSON.stringify({
          body: articleBody
        })
      })
      const responseData = await response.json()
      textarea.value = responseData.summary
    } catch (e) {
      console.error(e)
    } finally {
      btn.disabled = false
      btn.innerText = 'もう一度生成する'
    }
  })
})
