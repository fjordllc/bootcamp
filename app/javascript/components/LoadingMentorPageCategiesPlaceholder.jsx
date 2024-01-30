import React from 'react'
import MentorPageLoadingView from './MentorPageLoadingView'

const LoadingMentorPageCategiesPlaceholder = () => {
  const rowsForCategories = 12
  const columnsForCategories = 3

  return (
    <MentorPageLoadingView
      rows={rowsForCategories}
      columns={columnsForCategories}
    />
  )
}

export default LoadingMentorPageCategiesPlaceholder
