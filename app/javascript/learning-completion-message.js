document.addEventListener('DOMContentLoaded', () => {
  const modal = document.querySelector('#modal-learning_completion')
  if (!modal) {
    return null
  }

  const datasetNode = document.querySelector('#modal-learning_completion-data')

  if (datasetNode.dataset.shouldDisplayMessageAutomatically === 'true') {
    modal.checked = true
  }

  modal.addEventListener('change', () => {
    if (!modal.checked) {
      const practiceId = datasetNode.dataset.practiceId
      fetch(`/api/practices/${practiceId}/learning/completion_message`, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': token()
        },
        credentials: 'same-origin',
        redirect: 'manual'
      }).catch((error) => {
        console.warn('Failed to parsing', error)
      })
    }
  })

  function token() {
    const meta = document.querySelector('meta[name="csrf-token"]')
    return meta ? meta.getAttribute('content') : ''
  }
})
