function setupMentorMode() {
  const localStorage = window.localStorage
  const checkbox = document.querySelector('.js-mentor-mode__trigger')
  const body = document.body
  if (!checkbox) return
  if (checkbox.dataset.mentorModeInitialized === 'true') return

  if (localStorage.getItem('mentor-mode')) {
    checkbox.checked = false
    body.classList.remove('is-mentor-mode')
  } else {
    checkbox.checked = true
    body.classList.add('is-mentor-mode')
  }
  checkbox.addEventListener('click', () => {
    if (checkbox.checked) {
      localStorage.removeItem('mentor-mode')
      body.classList.add('is-mentor-mode')
    } else {
      localStorage.setItem('mentor-mode', 'off')
      body.classList.remove('is-mentor-mode')
    }
  })
  checkbox.dataset.mentorModeInitialized = 'true'
}

document.addEventListener('turbo:load', setupMentorMode)
document.addEventListener('DOMContentLoaded', setupMentorMode)
setupMentorMode()
