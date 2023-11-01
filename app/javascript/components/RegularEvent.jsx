import React from 'react'
import UserIcon from './UserIcon'

const RegularEvent = ({ regularEvent }) => {
  const categoryClass =
    regularEvent.category_class === 'reading_circle'
      ? 'is-reading-circle'
      : `is-${regularEvent.category_class}`

  return (
    <div className={'card-list-item ' + (regularEvent.wip ? 'is-wip' : '')}>
      <div className="card-list-item__inner">
        <div className={'card-list-item__label ' + categoryClass}>
          {regularEvent.category}
        </div>
        <div className="card-list-item__rows">
          <div className="card-list-item__row">
            <div className="card-list-item-title">
              <EventStatus event={regularEvent} />
              <EventTitle event={regularEvent} />
            </div>
          </div>
          <div className="card-list-item__row">
            <div className="card-list-item-meta">
              <div className="card-list-item-meta__items">
                <EventOrganizers event={regularEvent} />
                <EventDatetime event={regularEvent} />
                <Comments event={regularEvent} />
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

const EventStatus = ({ event }) => {
  return (
    <>
      {event.wip ? (
        <div className="a-list-item-badge is-wip">
          <span>WIP</span>
        </div>
      ) : (
        event.finished && (
          <div className="a-list-item-badge is-ended">
            <span>終了</span>
          </div>
        )
      )}
    </>
  )
}

const EventTitle = ({ event }) => {
  return (
    <h2 className="card-list-item-title__title" itemProp="name">
      <a
        className="card-list-item-title__link a-text-link"
        href={event.url}
        itemProp="url">
        {event.title}
      </a>
    </h2>
  )
}

const EventOrganizers = ({ event }) => {
  return (
    <>
      {event.organizers.length > 0 && (
        <div className="card-list-item-meta__item">
          <div className="a-meta">
            <div className="a-meta__label">主催</div>
            <div className="a-meta__value">
              <div className="card-list-item__user-icons">
                {event.organizers.map((organizer) => (
                  <UserIcon
                    key={organizer.id}
                    user={organizer}
                    blockClassSuffix="card-list-item"
                  />
                ))}
              </div>
            </div>
          </div>
        </div>
      )}
    </>
  )
}

const EventDatetime = ({ event }) => {
  return (
    <div className="card-list-item-meta__item">
      <time className="a-meta" dateTime={event.start_at}>
        <span className="a-meta__label">開催日時</span>
        <span className="a-meta__value">
          {event.holding_cycles} {event.start_at_localized} 〜{' '}
          {event.end_at_localized}
        </span>
      </time>
    </div>
  )
}

const Comments = ({ event }) => {
  return (
    <>
      {event.comments_count > 0 && (
        <div className="card-list-item-meta__item">
          <div className="a-meta">コメント({event.comments_count})</div>
        </div>
      )}
    </>
  )
}

export default RegularEvent
