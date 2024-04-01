import React from 'react'
import { useWatch } from './useWatch'

const WatchToggle = ({ watchableId, watchableType }) => {
  const { isWatched, handleCreateWatch, handleDeleteWatch } = useWatch(
    watchableId,
    watchableType
  )

  return isWatched ? (
    <button
      id="watch-button"
      className="a-watch-button a-button is-sm is-block is-active is-main"
      onClick={handleDeleteWatch}>
      Watch中
    </button>
  ) : (
    <button
      id="watch-button"
      className="a-watch-button a-button is-sm is-block is-inactive is-muted"
      onClick={handleCreateWatch}>
      Watch
    </button>
  )
}

export default WatchToggle
