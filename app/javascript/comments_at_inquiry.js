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

  const initialComments = []
  const commentTotalCount = comments.length
  let commentRemaining = 0
  let nextCommentAmount = 0
  if (commentTotalCount <= 8) {
    comments.forEach((comment) => {
      initialComments.push(comment)
    })
  } else {
    for (let i = 1; i <= 8; i++) {
      initialComments.push(comments[commentTotalCount - i])
    }
    commentRemaining = commentTotalCount - 8

    if (commentRemaining <= 8) {
      nextCommentAmount = commentRemaining
    } else {
      nextCommentAmount = `8 / ${commentRemaining}`
    }
  }

  setForloadedComment(initialComments)

  const moreCommentButton = document.querySelector(
    '.a-button.is-lg.is-text.is-block'
  )
  const moreComments = document.querySelector('.thread-comments-more')
  moreCommentButton.addEventListener('click', () => {
    const nextComments = []
    if (commentRemaining <= 8) {
      for (let i = 1; i <= commentRemaining; i++) {
        nextComments.push(comments[commentRemaining - i])
      }
      setForloadedComment(nextComments)
      commentRemaining = 0
      moreComments.style.display = 'none'
    } else {
      for (let i = 1; i <= 8; i++) {
        nextComments.push(comments[commentRemaining - i])
      }
      commentRemaining = commentRemaining - 8
      setForloadedComment(nextComments)
      if (commentRemaining <= 8) {
        nextCommentAmount = commentRemaining
        const commentText = `前のコメント（ ${nextCommentAmount} ）`
        moreCommentButton.textContent = commentText
      } else {
        nextCommentAmount = `8 / ${commentRemaining}`
        const commentText = `前のコメント（ ${nextCommentAmount} ）`
        moreCommentButton.textContent = commentText
      }
    }
  })

  // // moreCommentsの内容を書き換える処理として、この辺りを関数化したらいいかも
  const commentText = `前のコメント（ ${nextCommentAmount} ）`
  if (commentRemaining > 0) {
    moreComments.style.display = 'block'
    moreCommentButton.textContent = commentText
  }

  // function displayMoreComments() {}

  function setForloadedComment(comments) {
    comments.forEach((comment) => {
      comment.style.display = ''
      setComment(comment)
    })
  }
})
