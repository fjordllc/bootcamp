document.addEventListener('DOMContentLoaded', () => {
  const comments = document.querySelectorAll('.comment')
  const loadingContent = document.querySelector('.loading-content')
  const commentContent = document.querySelector(
    '#comments.thread-comments.loaded'
  )
  if (comments) {
    loadingContent.style.display = 'none'
    commentContent.style.display = 'block'
  }
})
