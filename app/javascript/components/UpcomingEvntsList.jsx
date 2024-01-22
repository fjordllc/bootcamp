import React from 'react'
import useSWR from 'swr'
import fetcher from '../fetcher'
import LoadingListPlaceholder from './LoadingListPlaceholder'

export default function UpcomingEventsList() {
  const { data, error } = useSWR(`/api/upcoming_events`, fetcher)

  if (error) return <>エラーが発生しました。</>
  if (!data) {
    return (
      <div className="page-body">
        <div className="container is-md">
          <LoadingListPlaceholder />
        </div>
      </div>
    )
  }

  return (
    <div>
      <header>
        <h2>近日開催のイベント</h2>
      </header>
      <div>
        <EventItems label="今日開催" events={data.todayEvents} />
        <EventItems label="明日開催" events={data.tomorrowEvents} />
        <EventItems label="明後日開催" events={data.dayAfterTomorrowEvents} />
      </div>
      <hr />
      <footer>
        <div>
          <a href="data.allEventsPath">全てのイベント（参加登録はこちらから</a>
        </div>
      </footer>
    </div>
  )
}

const EventItems = ({ label, events }) => {
  return (
    <div>
      <div>{label}</div>
      {isPresented(events) ? (
        events.map((event) => <EventCard key={event.id} event={event} />)
      ) : (
        <div>{label}のイベントはありません</div>
      )}
    </div>
  )
}

const EventCard = ({ event }) => {
  switch (event.type) {
    case 'Event':
      return <SpecialEventRow specialEvent={event} />
    case 'RegularEvent':
      return <RegularEventRow event={event} />
  }
}

const SpecialEventRow = ({ specialEvent }) => {
  return (
    <div>
      <span>
        特別
        <br />
        イベント
      </span>
      <header>
        <h2>
          <a href={specialEvent.link}>
            {specialEvent.participants.include(currentUser) && (
              <span>参加</span>
            )}
            <span>{specialEvent.title}</span>
          </a>
        </h2>
      </header>
      <div>
        <time>
          <span>開催日時</span>
          <span>{specialEvent.startAt}</span>
        </time>
        <div>{specialEvent.jobHunting && <span>就活関連イベント</span>}</div>
      </div>
    </div>
  )
}

const RegularEventRow = ({ event }) => {}

function isPresented(obj) {
  return obj && Object.keys(obj).length !== 0
}
