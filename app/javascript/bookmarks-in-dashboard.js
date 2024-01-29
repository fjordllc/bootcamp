import React from 'react'
import ReactDOM from 'react-dom'
import BookmarksInDashboard from './components/BookmarksInDashboard.jsx'

document.addEventListener('DOMContentLoaded', () => {
  if (document.getElementById('a-card-react')) {
    const bookmarksDomNode = document.getElementById('a-card-react')
    ReactDOM.render(
      <BookmarksInDashboard removeComponent={removeComponent} />,
      bookmarksDomNode
    )
  }
})

function removeComponent() {
  const bookmarksDomNode = document.getElementById('a-card-react')
  ReactDOM.unmountComponentAtNode(bookmarksDomNode)
  // const root = ReactDOM.createRoot(bookmarksDomNode)
  // root.unmount()
}
