import React from 'react'
import ListComment from './ListComment'

export default function Report({ report, currentUserId, displayUserIcon }) {
  return (
    <div className={`card-list-item ${report.wip ? 'is-wip' : ''}`}>
      <div className="card-list-item__inner">
        {displayUserIcon && <DisplayUserIcon report={report} />}
        <div className="card-list-item__rows">
          <div className="card-list-item__row">
            <header className="card-list-item-title">
              <div className="card-list-item-title__start">
                {report.wip && (
                  <div className="a-list-item-badge is-wip">
                    <span>WIP</span>
                  </div>
                )}
                <h2 className="card-list-item-title__title">
                  <a
                    className="card-list-item-title__link a-text-link js-unconfirmed-link"
                    href={report.url}>
                    <img
                      className="card-list-item-title__emotion-image"
                      src={`/images/emotion/${report.emotion}.svg`}
                      alt={report.emotion}
                    />
                    {report.title}
                  </a>
                </h2>
                {currentUserId === report.user.id && (
                  <ReportListItemActions report={report} />
                )}
              </div>
            </header>
          </div>
          <div className="card-list-item__row">
            <div className="card-list-item-meta">
              <div className="card-list-item-meta__items">
                <div className="card-list-item-meta__item">
                  <a className="a-user-name" href={report.user.url}>
                    {report.user.long_name}
                  </a>
                </div>
                <div className="card-list-item-meta__item">
                  <time className="a-meta">{`${report.reportedOn}の日報`}</time>
                </div>
              </div>
            </div>
            {report.hasAnyComments && <ListComment report={report} />}
          </div>
        </div>
        {report.hasCheck && (
          <div className="stamp stamp-approve">
            <h2 className="stamp__content is-title">確認済</h2>
            <time className="stamp__content is-created-at">
              {report.checkDate}
            </time>
            <div className="stamp__content is-user-name">
              <div className="stamp__content-inner">{report.checkUserName}</div>
            </div>
          </div>
        )}
      </div>
    </div>
  )
}

const DisplayUserIcon = ({ report }) => {
  const roleClass = `is-${report.user.primary_role}`

  return (
    <div className="card-list-item__user">
      <a href={report.user.url} className="card-list-item__user-link">
        <span className={`a-user-role ${roleClass}`}>
          <img
            className="card-list-item__user-icon a-user-icon"
            src={report.user.avatar_url}
            title={report.user.login_name}
            alt={report.user.login_name}
          />
        </span>
      </a>
    </div>
  )
}

const ReportListItemActions = ({ report }) => {
  return (
    <div className="card-list-item-title__end">
      <label className="card-list-item-actions__trigger" htmlFor={report.id}>
        <i className="fa-solid fa-ellipsis-h"></i>
      </label>
      <div className="card-list-item-actions">
        <input className="a-toggle-checkbox" type="checkbox" id={report.id} />
        <div className="card-list-item-actions__inner">
          <ul className="card-list-item-actions__items">
            <li className="card-list-item-actions__item">
              <a
                className="card-list-item-actions__action"
                href={report.editURL}>
                <i className="fa-solid fa-pen">内容変更</i>
              </a>
            </li>
            <li className="card-list-item-actions__item">
              <a
                className="card-list-item-actions__action"
                href={report.newURL}>
                <i className="fa-solid fa-copy">コピー</i>
              </a>
            </li>
          </ul>
          <label className="a-overlay" htmlFor={report.id}></label>
        </div>
      </div>
    </div>
  )
}
