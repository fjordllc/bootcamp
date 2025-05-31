import React from 'react'
import Following from './Following.jsx'
import UserActivityCounts from './UserActivityCounts.jsx'
import UserSns from './UserSns.jsx'
import UserTags from './UserTags.jsx'
import UserPracticeProgress from './UserPracticeProgress.jsx'

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

  const roleClass = () => `is-${user.primary_role}`
  const joiningStatusClass = () => `is-${user.joining_status}`

  return (
    <div className="col-xxxl-2 col-xxl-3 col-xl-4 col-lg-4 col-md-6 col-xs-12">
      <div className="users-item is-react">
        <div
          className={`users-item__inner a-card ${roleClass()} ${joiningStatusClass()}`}>
          {currentUser &&
            (currentUser.mentor || currentUser.admin) &&
            user.student_or_trainee && (
              <div className="users-item__inactive-message-container is-only-mentor">
                {user.roles.includes('retired') && (
                  <div className="users-item__inactive-message">
                    退会しました
                  </div>
                )}
                {user.roles.includes('hibernationed') && (
                  <div className="users-item__inactive-message">
                    休会中: {user.hibernated_at}〜(
                    {user.hibernation_elapsed_days}日経過)
                  </div>
                )}
                {!user.active && (
                  <div className="users-item__inactive-message">
                    1ヶ月以上ログインがありません
                  </div>
                )}
              </div>
            )}
          <header className="users-item__header">
            <div className="users-item__header-inner">
              <div className="users-item__header-start">
                <div className="users-item__icon">
                  <a href={user.url}>
                    <span
                      className={`a-user-role ${roleClass()} ${joiningStatusClass()}`}>
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
                      <div className="card-list-item-title__end">
                        <a
                          className="card-list-item-title__title is-lg a-text-link"
                          href={user.url}>
                          {user.login_name}
                        </a>
                      </div>
                    </div>
                  </div>
                  <div className="card-list-item__row">
                    <div className="card-list-item-meta">
                      <div className="card-list-item-meta__items">
                        <div className="card-list-item-meta__item">
                          <div className="a-meta">{user.name}</div>
                        </div>
                        <div className="card-list-item-meta__item">
                          {user.discord_profile.times_url ? (
                            <a
                              className="a-meta"
                              href={user.discord_profile.times_url}>
                              <i className="fa-brands fa-discord"></i>
                              {user.discord_profile.account_name}
                            </a>
                          ) : (
                            <div className="a-meta">
                              <i className="fa-brands fa-discord"></i>
                              {user.discord_profile.account_name}
                            </div>
                          )}
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
                <UserSns user={user} />
              </div>
            </div>
            <UserActivityCounts user={user} />
          </header>
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
          <hr className="a-border-tint" />
          <footer className="card-footer users-item__footer">
            <div className="card-main-actions">
              <ul className="card-main-actions__items">
                {currentUser.id !== user.id &&
                  currentUser.adviser &&
                  user.company &&
                  currentUser.company_id === user.company.id && (
                    <li className="card-main-actions__item">
                      <div className="a-button is-disabled is-sm is-block">
                        <i className="fa-solid fa-check"></i>
                        <span>自社研修生</span>
                      </div>
                    </li>
                  )}
                {currentUser.id !== user.id && (
                  <li className="card-main-actions__item">
                    <Following
                      isFollowing={user.isFollowing}
                      userId={user.id}
                      isWatching={user.isWatching}
                    />
                  </li>
                )}
                {currentUser.admin && user.talkUrl && (
                  <li className="card-main-actions__item is-only-mentor">
                    <a
                      className="a-button is-secondary is-sm is-block"
                      href={user.talkUrl}>
                      相談部屋
                    </a>
                  </li>
                )}
              </ul>
            </div>
          </footer>
        </div>
      </div>
    </div>
  )
}
