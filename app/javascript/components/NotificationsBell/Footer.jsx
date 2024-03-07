import React from 'react'

export default function Footer({ notificationsCount }) {
  const openUnconfirmedItems = () => {
    const links = document.querySelectorAll(
      '.header-dropdown__item-link.unconfirmed_link'
    )
    links.forEach((link) => {
      window.open(link.href, '_target', 'noopener')
    })
  }

  if (!notificationsCount) return null

  return (
    <footer className="header-dropdown__footer">
      <a
        href="/notifications/allmarks"
        className="header-dropdown__footer-link"
        data-method="post">
        全て既読にする
      </a>
      <button
        className="header-dropdown__footer-link"
        onClick={openUnconfirmedItems}>
        全て別タブで開く
      </button>
    </footer>
  )
}
