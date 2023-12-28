import React from 'react'

export default function UserActivityCounts({ user }) {
  if (!user.student_or_trainee) {
    return null
  }

  return (
    <div className="card-counts mt-3">
      <dl className="card-counts__items">
        <div className="card-counts__item">
          <div className="card-counts__item-inner">
            <dt className="card-counts__item-label">日報</dt>
            <dd
              className={`card-counts__item-value ${
                user.report_count === 0 ? 'is-empty' : ''
              }`}>
              {user.report_count}
            </dd>
          </div>
        </div>
        <div className="card-counts__item">
          <div className="card-counts__item-inner">
            <dt className="card-counts__item-label">提出物</dt>
            <dd
              className={`card-counts__item-value ${
                user.product_count === 0 ? 'is-empty' : ''
              }`}>
              {user.product_count}
            </dd>
          </div>
        </div>
        <div className="card-counts__item">
          <div className="card-counts__item-inner">
            <dt className="card-counts__item-label">コメント</dt>
            <dd
              className={`card-counts__item-value ${
                user.comment_count === 0 ? 'is-empty' : ''
              }`}>
              {user.comment_count}
            </dd>
          </div>
        </div>
        <div className="card-counts__item">
          <div className="card-counts__item-inner">
            <dt className="card-counts__item-label">質問</dt>
            <dd
              className={`card-counts__item-value ${
                user.question_count === 0 ? 'is-empty' : ''
              }`}>
              {user.question_count}
            </dd>
          </div>
        </div>
        <div className="card-counts__item">
          <div className="card-counts__item-inner">
            <dt className="card-counts__item-label">回答</dt>
            <dd
              className={`card-counts__item-value ${
                user.answer_count === 0 ? 'is-empty' : ''
              }`}>
              {user.answer_count}
            </dd>
          </div>
        </div>
      </dl>
    </div>
  )
}
