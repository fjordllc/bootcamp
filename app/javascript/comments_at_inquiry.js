import initializeComment from 'initialize_comment.js'

document.addEventListener('DOMContentLoaded', () => {
  const comments = document.querySelectorAll('.comment')
  const loadingContent = document.querySelector('.loading-content')
  if (!loadingContent) {
    return
  }
  const commentContent = document.querySelector(
    '#comments.thread-comments.loaded'
  )
  if (comments) {
    loadingContent.style.display = 'none'
    commentContent.style.display = 'block'
  }

  const initialComments = []
  const commentTotalCount = comments.length
  const initialLimit = 8
  const incrementSize = 8
  let commentRemaining = 0
  const nextCommentAmount = 0

  if (commentTotalCount <= initialLimit) {
    comments.forEach((comment) => {
      initialComments.push(comment)
    })
  } else {
    for (let i = 1; i <= initialLimit; i++) {
      initialComments.push(comments[commentTotalCount - i])
    }
    setComments(initialComments)
    commentRemaining = commentTotalCount - initialLimit

    const moreCommentButton = document.querySelector(
      '.a-button.is-lg.is-text.is-block'
    )
    const moreComments = document.querySelector('.thread-comments-more')
    if (commentRemaining > 0) {
      moreComments.style.display = 'block'
    }
    displayMoreComments(commentRemaining, nextCommentAmount, moreCommentButton)
  }

  const moreCommentButton = document.querySelector(
    '.a-button.is-lg.is-text.is-block'
  )
  const moreComments = document.querySelector('.thread-comments-more')
  moreCommentButton.addEventListener('click', () => {
    const nextComments = []
    if (commentRemaining <= incrementSize) {
      for (let i = 1; i <= commentRemaining; i++) {
        nextComments.push(comments[commentRemaining - i])
      }
      setComments(nextComments)
      commentRemaining = 0
      moreComments.style.display = 'none'
    } else {
      for (let i = 1; i <= incrementSize; i++) {
        nextComments.push(comments[commentRemaining - i])
      }
      commentRemaining = commentRemaining - incrementSize
      setComments(nextComments)
      displayMoreComments(
        commentRemaining,
        nextCommentAmount,
        moreCommentButton
      )
    }
  })

  function displayMoreComments(
    commentRemaining,
    nextCommentAmount,
    moreCommentButton
  ) {
    if (commentRemaining <= incrementSize) {
      nextCommentAmount = commentRemaining
      const commentText = `前のコメント（ ${nextCommentAmount} ）`
      moreCommentButton.textContent = commentText
    } else {
      nextCommentAmount = `${incrementSize} / ${commentRemaining}`
      const commentText = `前のコメント（ ${nextCommentAmount} ）`
      moreCommentButton.textContent = commentText
    }
  }

  function setComments(comments) {
    comments.forEach((comment) => {
      comment.style.display = ''
      initializeComment(comment)
    })
  }
})
