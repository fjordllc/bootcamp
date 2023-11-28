import React from 'react'
import { useWatch } from './useWatch'

const WatchToggle = ({ watchableId, watchableType }) => {
  const { watchId, handleCreateWatch, handleDeleteWatch} = useWatch(watchableId, watchableType)
  const watchLabel = watchId ? 'Watch中' : 'Watch'

  return (
    <div
      className={`watch-button a-watch-button a-button is-sm is-block ${
        watchId ? 'is-active is-main' : 'is-inactive is-muted'
      }`}
      onClick={watchId ? handleDeleteWatch : handleCreateWatch}
    >
      {watchLabel}
    </div>
  )
}

export default WatchToggle
