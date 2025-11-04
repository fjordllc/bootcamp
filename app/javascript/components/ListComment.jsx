import React from 'react'
import userIconFrameClass from '../user-icon-frame-class.js'

export default function ListComment({ report }) {
  return (
    <>
      <hr className="card-list-item__row-separator"></hr>
      <div className="card-list-item__row">
        <div className="card-list-item-meta">
          <div className="card-list-item-meta__items">
            <div className="card-list-item-meta__item">
              <div className="a-meta">
                コメント（{report.numberOfComments}）
              </div>
            </div>
            <div className="card-list-item-meta__item">
              <div className="card-list-item__user-icons">
                {report.comments.map((comment) => {
                  return (
                    <a
                      className="card-list-item__user-icons-icon"
                      href={`/users/${comment.user_id}`}
                      key={comment.user_id}>
                      <span
                        className={userIconFrameClass(
                          comment.primary_role,
                          comment.joining_status
                        )}>
                        <img className="a-user-icon" src={comment.user_icon} />
                      </span>
                    </a>
                  )
                })}
              </div>
            </div>
            <div className="card-list-item-meta__item">
              <time
                className="a-meta"
                dateTime={report.lastCommentDatetime}
                pubdate="'pubdate'">{`〜 ${report.lastCommentDate}`}</time>
            </div>
            <div className="card-list-item-meta__item"></div>
          </div>
        </div>
      </div>
    </>
  )
}
