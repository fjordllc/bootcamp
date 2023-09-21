import React from 'react'
import UserIcon from './UserIcon'

const RegularEvent = ({ regularEvent }) => {
  const categoryClass = regularEvent.category_class === "reading_circle" ? "is-reading-circle" : `is-${regularEvent.category_class}`

  return (
    <div className={"card-list-item " + (regularEvent.wip ? "is-wip" : "")}>
      <div className="card-list-item__inner">
        <div className={"card-list-item__label " + categoryClass}>
          {regularEvent.category}
        </div>
        <div className="card-list-item__rows">
          <div className="card-list-item__row">
            <div className="card-list-item-title">
              {regularEvent.wip ? (
                <div className="a-list-item-badge is-wip">
                  <span>WIP</span>
                </div>
              ) : regularEvent.finished && (
                <div className="a-list-item-badge is-ended">
                  <span>終了</span>
                </div>
              )}
              <h2 className="card-list-item-title__title" itemProp="name">
                <a className="card-list-item-title__link a-text-link" href={regularEvent.url} itemProp="url">
                  {regularEvent.title}
                </a>
              </h2>
            </div>
          </div>
          <div className="card-list-item__row">
            <div className="card-list-item-meta">
              <div className="card-list-item-meta__items">
                {regularEvent.organizers.length > 0 && (
                  <div className="card-list-item-meta__item">
                      <div className="a-meta">
                        <div className="a-meta__label">主催</div>
                        <div className="a-meta__value">
                          <div className="card-list-item__user-icons">
                          {regularEvent.organizers.map(organizer =>
                            <UserIcon
                              key={organizer.id}
                              user={organizer}
                              blockClassSuffix='card-list-item'
                            />
                          )}
                          </div>
                        </div>
                      </div>
                  </div>
                )}
                <div className="card-list-item-meta__item">
                  <time className="a-meta" dateTime={regularEvent.start_at}>
                    <span className="a-meta__label">開催日時</span>
                    <span className="a-meta__value">
                      {regularEvent.holding_cycles} {regularEvent.start_at_localized} 〜 {regularEvent.end_at_localized}
                    </span>
                  </time>
                </div>
                {regularEvent.comments_count > 0 && (
                  <div className="card-list-item-meta__item">
                    <div className="a-meta">
                      コメント({regularEvent.comments_count})
                    </div>
                  </div>
                )
                }
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

export default RegularEvent
