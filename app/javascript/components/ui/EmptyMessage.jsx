import React from 'react'

export default function EmptyMessage({ children }) {
  return (
    <div className="o-empty-message">
      <div className="o-empty-message__icon">
        <i className="fa-regular fa-smile" />
      </div>
      <p className="o-empty-message__text">
        { children }
      </p>
    </div>
  )
}
