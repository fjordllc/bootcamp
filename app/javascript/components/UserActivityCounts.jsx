import React from 'react'

export default function UserActivityCounts({ user }) {
  if (!user.student_or_trainee) {
    return null
  }

  const activities = [
    { name: '日報', count: user.report_count, url: `${user.url}/reports` },
    { name: '提出物', count: user.product_count, url: `${user.url}/products` },
    {
      name: 'コメント',
      count: user.comment_count,
      url: `${user.url}/comments`
    },
    { name: '質問', count: user.question_count, url: `${user.url}/questions` },
    { name: '回答', count: user.answer_count, url: `${user.url}/answers` }
  ]

  return (
    <div className="card-counts is-users mt-3">
      <dl className="card-counts__items">
        {activities.map((activity) => (
          <div key={activity.name} className="card-counts__item">
            <div className="card-counts__item-inner">
              <dt className="card-counts__item-label">{activity.name}</dt>
              <dd
                className={`card-counts__item-value ${
                  activity.count === 0 ? 'is-empty' : ''
                }`}>
                {activity.count === 0 ? (
                  <span>{activity.count}</span>
                ) : (
                  <a href={activity.url}>{activity.count}</a>
                )}
              </dd>
            </div>
          </div>
        ))}
      </dl>
    </div>
  )
}
