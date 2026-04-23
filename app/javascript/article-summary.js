document.addEventListener('DOMContentLoaded', () => {
  const btn = document.getElementById('btn-generate-summary')
  const textarea = document.getElementById('summary-text-area')
  if (!btn || !textarea) return
  btn.addEventListener('click', async (e) => {
    e.preventDefault()
    try {
      btn.disabled = true
      btn.innerHTML = `<svg class="animate-spin h-5 w-5 border-2 border-indigo-500 border-t-transparent rounded-full" viewBox="0 0 24 24"></svg> ${btn.innerText}`
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
      alert('サマリーの生成に失敗しました')
    } finally {
      btn.disabled = false
      btn.innerHTML = btn.innerText
    }
  })
})
