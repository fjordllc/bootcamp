import { initializeComment } from 'initializeComment'

document.addEventListener('DOMContentLoaded', async () => {
  const comments = document.querySelectorAll('.thread-comment:not(.loading)')
  const loadingContent = document.querySelector('.loading-content')
  if (!loadingContent) {
    return
  }
  const commentContent = document.querySelector(
    '#comments.thread-comments.loaded'
  )
  if (!commentContent) {
    return
  }
  if (comments) {
    loadingContent.classList.add('is-hidden')
    commentContent.classList.remove('is-hidden')
  }

  const initialComments = []
  const commentTotalCount = comments.length
  const initialLimit = 8
  const incrementSize = 8
  let commentRemaining = 0
  const nextCommentAmount = 0
  const moreComments = document.querySelector('.thread-comments-more')
  const moreCommentButton = moreComments?.querySelector('button')
  if (!moreCommentButton || !moreComments) {
    setComments(comments)
    return
  }

  if (moreComments.dataset.commentsUrl) {
    commentRemaining = Number(moreComments.dataset.commentRemaining)
    setComments(comments)
    displayMoreComments(commentRemaining, nextCommentAmount, moreCommentButton)

    const commentItems = document.querySelector('.thread-comments__items')
    let beforeId =
      commentItems.querySelector('.thread-comment').dataset.comment_id
    const loadComments = async (parameter, updateRemaining = true) => {
      const response = await fetch(
        `${moreComments.dataset.commentsUrl}?${parameter}`
      )
      if (!response.ok) throw new Error(`HTTP ${response.status}`)

      const template = document.createElement('template')
      template.innerHTML = await response.text()
      const loadedComments = Array.from(
        template.content.querySelectorAll('.thread-comment')
      )
      commentItems.prepend(template.content)
      setComments(loadedComments)
      if (!updateRemaining) return

      beforeId = loadedComments[0]?.dataset.comment_id || beforeId
      commentRemaining = Number(response.headers.get('X-Comment-Remaining'))
      if (commentRemaining > 0) {
        moreComments.classList.remove('is-hidden')
        displayMoreComments(
          commentRemaining,
          nextCommentAmount,
          moreCommentButton
        )
      } else {
        moreComments.classList.add('is-hidden')
      }
    }

    const commentAnchor = location.hash
    const anchorId = commentAnchor.match(/^#comment_(\d+)$/)?.[1]
    if (anchorId && !document.getElementById(`comment_${anchorId}`)) {
      try {
        await loadComments(`target=${encodeURIComponent(anchorId)}`, false)
        document.getElementById(`comment_${anchorId}`)?.scrollIntoView()
      } catch (error) {
        console.warn(error)
      }
    }

    moreCommentButton.addEventListener('click', async () => {
      moreCommentButton.disabled = true
      try {
        await loadComments(`before=${encodeURIComponent(beforeId)}`)
      } catch (error) {
        console.warn(error)
      } finally {
        moreCommentButton.disabled = false
      }
    })
    return
  }

  if (commentTotalCount <= initialLimit) {
    comments.forEach((comment) => {
      initialComments.push(comment)
    })
  } else {
    for (let i = 1; i <= initialLimit; i++) {
      initialComments.push(comments[commentTotalCount - i])
    }
    commentRemaining = commentTotalCount - initialLimit

    if (commentRemaining > 0) {
      moreComments.classList.remove('is-hidden')
    }
    displayMoreComments(commentRemaining, nextCommentAmount, moreCommentButton)
  }
  setComments(initialComments)

  const commentAnchor = location.hash
  if (commentAnchor && commentAnchor.startsWith('#comment_')) {
    const anchorElement = document.getElementById(commentAnchor.slice(1))
    if (anchorElement && anchorElement.classList.contains('is-hidden')) {
      const commentsArray = Array.from(comments)
      const targetIndex = commentsArray.indexOf(anchorElement)
      if (targetIndex !== -1) {
        const commentsToReveal = commentsArray.slice(
          targetIndex,
          commentTotalCount - initialLimit
        )
        setComments(commentsToReveal)
        commentRemaining = targetIndex
        if (commentRemaining === 0) {
          moreComments.classList.add('is-hidden')
        } else {
          displayMoreComments(commentRemaining, 0, moreCommentButton)
        }
      }
    }
    if (anchorElement) {
      requestAnimationFrame(() => {
        requestAnimationFrame(() => {
          anchorElement.scrollIntoView({ behavior: 'instant' })
        })
      })
    }
  }

  moreCommentButton.addEventListener('click', () => {
    const nextComments = []
    if (commentRemaining <= incrementSize) {
      for (let i = 1; i <= commentRemaining; i++) {
        nextComments.push(comments[commentRemaining - i])
      }
      setComments(nextComments)
      commentRemaining = 0
      moreComments.classList.add('is-hidden')
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
      comment.classList.remove('is-hidden')
      initializeComment(comment)
    })
  }
})
