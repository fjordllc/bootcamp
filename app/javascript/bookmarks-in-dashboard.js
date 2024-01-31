import React from 'react'
import ReactDOM from 'react-dom'
import BookmarksInDashboard from './components/BookmarksInDashboard.jsx'

document.addEventListener('DOMContentLoaded', () => {
  if (document.getElementById('bookmarks-in-dashboard')) {
    const bookmarksDomNode = document.getElementById('bookmarks-in-dashboard')
    ReactDOM.render(
      <BookmarksInDashboard removeComponent={removeComponent} />,
      bookmarksDomNode
    )
  }
})

function removeComponent() {
  const bookmarksDomNode = document.getElementById('bookmarks-in-dashboard')
  bookmarksDomNode.remove()
}
