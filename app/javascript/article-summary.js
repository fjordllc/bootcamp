document.addEventListener('DOMContentLoaded', () => {
  const btn = document.getElementById('btn-generate-summary')
  const textarea = document.getElementById('summary-text-area')
  if (!btn || !textarea) return
  const originalInnerHTML = btn.innerHTML
  btn.addEventListener('click', async (e) => {
    try {
      btn.disabled = true
      btn.innerHTML = `<svg class="animate-spin h-5 w-5 border-2 border-indigo-500 border-t-transparent rounded-full" viewBox="0 0 24 24"></svg> ${btn.innerText}`
      const articleBody = document.querySelector('[name="article[body]"]').value
      const response = await fetch('/articles/create_summary', {
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

      if (!response.ok) {
        let errorMessage = 'サマリーの生成に失敗しました'
        try {
          const errorData = await response.json()
          if (errorData.error) {
            errorMessage = errorData.error
          }
        } catch {
          errorMessage = await response.text() || errorMessage
        }
        throw new Error(errorMessage)
      }

      const responseData = await response.json()
      textarea.value = responseData.summary
    } catch (error) {
      console.error(error)
      alert('サマリーの生成に失敗しました')
    } finally {
      btn.disabled = false
      btn.innerHTML = originalInnerHTML
    }
  })
})
