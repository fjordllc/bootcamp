import setComment from 'set_comment.js'

document.addEventListener('DOMContentLoaded', () => {
  // ローディング処理を関数にするか？
  const comments = document.querySelectorAll('.comment')
  const loadingContent = document.querySelector('.loading-content')
  const commentContent = document.querySelector(
    '#comments.thread-comments.loaded'
  )
  if (comments) {
    loadingContent.style.display = 'none'
    commentContent.style.display = 'block'
  }

  displayMoreComments(comments)

  comments.forEach((comment) => {
    setComment(comment)
  })
})

function displayMoreComments(comments) {
  const commentLimit = 8
  let commentOffset = 0
  const incrementCommentSize = 8
  const commentTotalCount = comments.length
  const moreCommentButton = document.querySelector(
    '.a-button.is-lg.is-text.is-block'
  )
  const allCommentsIsLoaded = commentLimit + commentOffset >= commentTotalCount
  if (!allCommentsIsLoaded) {
    commentOffset += commentLimit
  }
  const commentRemaining = commentTotalCount - commentOffset

  const nextCommentAmount =
    commentRemaining > incrementCommentSize
      ? `${incrementCommentSize} / ${commentRemaining}`
      : commentRemaining
  const commentText = `前のコメント（ ${nextCommentAmount} ）`
  const moreComments = document.querySelector('.thread-comments-more')
  if (!allCommentsIsLoaded) {
    moreComments.style.display = 'block'
    moreCommentButton.textContent = commentText
  }
}
