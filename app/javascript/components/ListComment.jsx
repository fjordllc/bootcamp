import React from 'react'
import CommentUserIcon from './CommentUserIcon'

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
                    <CommentUserIcon comment={comment} key={comment.user_id} />
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
