import React from 'react'
import UserSns from './UserSns.jsx'
import UserActivityCounts from './UserActivityCounts.jsx'
import UserTags from './UserTags.jsx'
import UserPracticeProgress from './UserPracticeProgress.jsx'
import Following from './Following.jsx'

export default function User({ user, currentUser }) {
  const userDescParagraphs = () => {
    let description = user.description
    description =
      description.length <= 200
        ? description
        : description.substring(0, 200) + '...'
    const paragraphs = description.split(/\n|\r\n/).map((text, i) => {
      return {
        id: i,
        text: text
      }
    })
    return paragraphs
  }

  const roleClass = () => {
    return `is-${user.primary_role}`
  }

  return (
    <div className="col-xxl-3 col-xl-4 col-lg-4 col-md-6 col-xs-12">
      <div className="users-item">
        <div className={`users-item__inner a-card ${roleClass()}`}>
          {currentUser.mentor && user.student_or_trainee && !user.active && (
            <div className="users-item__inactive-message is-only-mentor">
              1ヶ月以上ログインがありません
            </div>
          )}
          <header className="users-item__header">
            <div className="users-item__header-inner">
              <div className="users-item__header-start">
                <div className="users-item__icon">
                  <a href={user.url}>
                    <span className={`a-user-role ${roleClass()}`}>
                      <img
                        className="users-item__user-icon-image a-user-icon"
                        title={user.icon_title}
                        alt={user.icon_title}
                        src={user.avatar_url}
                      />
                    </span>
                  </a>
                </div>
              </div>
              <div className="users-item__header-end">
                <div className="card-list-item__rows">
                  <div className="card-list-item__row">
                    <div className="card-list-item-title">
                      <a
                        className="card-list-item-title__title is-lg a-text-link"
                        href={user.url}>
                        {user.login_name}
                      </a>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </header>
          <UserSns user={user} />
          <UserActivityCounts user={user} />
          <div className="users-item__body">
            <div className="users-item__description a-short-text">
              {userDescParagraphs().map((paragraph) => (
                <p key={paragraph.id}>{paragraph.text}</p>
              ))}
            </div>
            <div className="users-item__tags">
              <UserTags user={user} />
            </div>
          </div>
          <UserPracticeProgress user={user} />
          <Following
            isFollowing={user.isFollowing}
            userId={user.id}
            isWatching={user.isWatching}
          />
        </div>
      </div>
    </div>
  )
}
