import React from 'react'
import dayjs from 'dayjs'
import ja from 'dayjs/locale/ja'
dayjs.locale(ja)

export default function Searchable({ searchable, word }) {
  const roleClass = `is-${searchable.primary_role}`
  const joiningStatusClass = `is-${searchable.joining_status}`
  const searchableClass = searchable.wip
    ? `is-wip is-${searchable.model_name}`
    : `is-${searchable.model_name}`

  const userUrl = `/users/${searchable.user_id}`
  const documentAuthorUserUrl = `/users/${searchable.document_author_id}`
  const talkUrl = `/talks/${searchable.talk_id}`

  const updatedAt = dayjs(searchable.updated_at).format(
    'YYYY年MM月DD日(dd) HH:mm'
  )
  const canDisplayTalk = searchable.model_name === 'user' && searchable.talk_id
  const currentUser = window.currentUser

  const labelContent =
    searchable.model_name === 'regular_event' ? (
      <span className="card-list-item__label-inner is-sm">
        定期
        <br />
        イベント
      </span>
    ) : searchable.model_name === 'event' ? (
      <span className="card-list-item__label-inner is-sm">
        特別
        <br />
        イベント
      </span>
    ) : searchable.model_name === 'practice' ? (
      <span className="card-list-item__label-inner">
        プラク
        <br />
        ティス
      </span>
    ) : (
      <span>{searchable.model_name_with_i18n}</span>
    )

  const badgeContent = searchable.wip ? (
    <div className="a-list-item-badge is-wip">
      <span>WIP</span>
    </div>
  ) : searchable.is_comment_or_answer ? (
    <div className="a-list-item-badge is-searchable">
      <span>コメント</span>
    </div>
  ) : searchable.is_user ? (
    <div className="a-list-item-badge is-searchable">
      <span>ユーザー</span>
    </div>
  ) : (
    ''
  )

  const summary = () => {
    const wordsPattern = word
      .trim()
      .replaceAll(/[.*+?^=!:${}()|[\]/\\]/g, '\\$&')
      .replaceAll(/\s+/g, '|')
    const pattern = new RegExp(wordsPattern, 'gi')
    if (word) {
      return searchable.summary.replaceAll(
        pattern,
        `<strong class='matched_word'>$&</strong>`
      )
    } else {
      return searchable.summary
    }
  }

  return (
    <div className={`card-list-item ${searchableClass}`}>
      <div className="card-list-item__inner">
        {searchable.is_user && (
          <div className="card-list-item__user">
            <a className="card-list-item__user-link" href={searchable.url}>
              <span
                className={`a-user-role ${roleClass} ${joiningStatusClass}`}>
                <img
                  className="card-list-item__user-icon a-user-icon"
                  src={searchable.avatar_url}
                  title={searchable.title}
                  alt={searchable.title}></img>
              </span>
            </a>
          </div>
        )}
        {!searchable.is_user && (
          <div className="card-list-item__label">{labelContent}</div>
        )}
        <div className="card-list-item__rows">
          <div className="card-list-item__row">
            <div className="card-list-item-title">
              {badgeContent}
              <div className="card-list-item-title__title">
                <a
                  className="card-list-item-title__link a-text-link"
                  href={searchable.url}>
                  {searchable.title}
                </a>
              </div>
            </div>
          </div>
          <div className="card-list-item__row">
            <div className="card-list-item__summary">
              <p dangerouslySetInnerHTML={{ __html: summary() }}></p>
            </div>
          </div>
          <div className="card-list-item__row">
            <div className="card-list-item-meta">
              <div className="card-list-item-meta__items">
                {!['practice', 'page', 'user'].includes(
                  searchable.model_name
                ) && (
                  <div className="card-list-item-meta__item">
                    <div className="card-list-item-meta__user">
                      <a
                        className="card-list-item-meta__icon-link"
                        href={userUrl}>
                        <span
                          className={`a-user-role ${roleClass} ${joiningStatusClass}`}>
                          <img
                            className="card-list-item-meta__icon a-user-icon"
                            src={searchable.avatar_url}
                            title={searchable.icon_title}
                            alt={searchable.icon_title}></img>
                        </span>
                      </a>
                      <a className="a-user-name" href={userUrl}>
                        {searchable.login_name}
                      </a>
                    </div>
                  </div>
                )}
                <div className="card-list-item-meta__item">
                  <div
                    className={`time a-meta datetime=${searchable.updated_at} pubdate="pubdate"`}>
                    {updatedAt}
                  </div>
                </div>
                {searchable.is_comment_or_answer && (
                  <div className="card-list-item-meta__item">
                    <div className="a-meta">
                      {'('}
                      <a className="a-user-name" href={documentAuthorUserUrl}>
                        {searchable.document_author_login_name}
                      </a>{' '}
                      {searchable.model_name_with_i18n}
                      {')'}
                    </div>
                  </div>
                )}
                {currentUser.roles.includes('admin') && canDisplayTalk && (
                  <div className="card-list-item-meta__item">
                    <a className="a-text-link" href={talkUrl}>
                      相談部屋
                    </a>
                  </div>
                )}
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
