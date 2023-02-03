import React from 'react'

export default function LoadingListPlaceholder() {
  const itemCount = 8
  return (
    <div className="card-list a-card is-loading">
      {[...Array(itemCount)].map((_, index) => {
        return <LoadingListItemPlaceholder key={index} />
      })}
    </div>
  )
}

function LoadingListItemPlaceholder() {
  return (
    <div className="card-list-item">
      <div className="card-list-item__inner">
        <div className="card-list-item__user">
          <div className="card-list-item__user-icon a-user-icon a-placeholder"></div>
        </div>
        <div className="card-list-item__rows">
          <div className="card-list-item__row">
            <div className="card-list-item-title a-placeholder"></div>
          </div>
          <div className="card-list-item__row">
            <div className="card-list-item-meta__items a-placeholder">
              <div className="card-list-item-meta__item"></div>
              <div className="card-list-item-meta__item"></div>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
