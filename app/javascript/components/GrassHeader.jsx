import React from 'react'

export default function GrassHeader({ currentUser, hideGrass, isDashboard }) {
  return (
    <header className="card-header is-sm">
      <h2 className="card-header__title">学習時間</h2>
      {currentUser &&
        window.currentUser.primary_role === 'graduate' &&
        isDashboard && (
          <button
            onClick={hideGrass}
            className="a-button is-xs is-muted-bordered">
            非表示
          </button>
        )}
    </header>
  )
}
