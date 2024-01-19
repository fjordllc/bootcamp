import React from 'react'
import { useWatch } from './useWatch'

const WatchToggle = ({ watchableId, watchableType }) => {
  const { watchExists, handleCreateWatch, handleDeleteWatch} = useWatch(watchableId, watchableType)
  const watchLabel = watchExists ? 'Watch中' : 'Watch'

  return (
    <button
      className={`watch-button a-watch-button a-button is-sm is-block ${
        watchExists ? 'is-active is-main' : 'is-inactive is-muted'
      }`}
      onClick={watchExists ? handleDeleteWatch : handleCreateWatch}
    >
      {watchLabel}
    </button>
  )
}

export default WatchToggle
