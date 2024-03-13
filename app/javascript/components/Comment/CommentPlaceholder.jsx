import React from 'react'

const Placeholder = () => {
  return (
    <div className="thread-comment">
      <div className="thread-comment__start">
        <div className="thread-comment__user-icon a-user-icon a-placeholder"></div>
      </div>
      <div className="thread-comment__end">
        <div className="a-card is-loading">
          <div className="card-header">
            <div className="thread-comment__title">
              <div className="thread-comment__title-link a-placeholder"></div>
            </div>
            <div className="thread-comment__created-at a-placeholder"></div>
          </div>
          <hr className="a-border-tint" />
          <div className="thread-comment__description">
            <div className="a-long-text is-md a-placeholder">
              <p></p>
              <p></p>
              <p></p>
              <p></p>
              <p></p>
              <p></p>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

const CommentPlaceholder = () => {
  const placeholderCount = 3
  return(
    <div id="comments" className="thread-comments loading">
      {Array.from({ length: placeholderCount }, (_, index) => (
        <Placeholder key={index} />
      ))}
    </div>
  )
}

export default CommentPlaceholder
