import React from 'react'
import MentorPageLoadingView from './MentorPageLoadingView'

const LoadingMentorPageCategoriesPlaceholder = () => {
  const columnsForCategories = 3
  const rowsForCategories = 12

  return (
    <MentorPageLoadingView
      columns={columnsForCategories}
      rows={rowsForCategories}
    />
  )
}

export default LoadingMentorPageCategoriesPlaceholder
