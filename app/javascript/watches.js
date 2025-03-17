document.addEventListener('DOMContentLoaded', () => {
  const localStorage = window.localStorage
  const editToggle = document.getElementById('card-list-tools__action')
  const deleteButtons = document.querySelectorAll('.a-watch-button')
  if (!editToggle) {
    window.addEventListener('beforeunload', function () {
      localStorage.removeItem('watchs-delete-mode')
    })
    return
  }

  if (localStorage.getItem('watchs-delete-mode') === 'on') {
    editToggle.checked = true
    deleteButtons.forEach((button) => {
      button.classList.remove('hidden')
    })
  } else {
    editToggle.checked = false
    deleteButtons.forEach((button) => {
      button.classList.add('hidden')
    })
  }

  editToggle.addEventListener('change', () => {
    if (editToggle.checked) {
      localStorage.setItem('watchs-delete-mode', 'on')
      deleteButtons.forEach((button) => {
        button.classList.remove('hidden')
      })
    } else {
      localStorage.removeItem('watchs-delete-mode')
      deleteButtons.forEach((button) => {
        button.classList.add('hidden')
      })
    }
  })
})
