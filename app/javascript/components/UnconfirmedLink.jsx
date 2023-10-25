import React, { useCallback } from 'react'

export default function UnconfirmedLink({ label }) {
  const openUnconfirmedItems = useCallback(() => {
    const links = document.querySelectorAll('.card-list-item-title__link')
    console.log(links)
    links.forEach((link) => {
      window.open(link.href, '_target', 'noopener')
    })
  }, [])

  return (
    <>
      <hr className="a-border-tint"></hr>
      <div className="card-footer">
        <div className="card-main-actions">
          <ul className="card-main-actions__items">
            <li className="card-main-actions__item">
              <button
                className="thread-unconfirmed-links-form__action a-button is-sm is-block is-secondary"
                onClick={openUnconfirmedItems}>
                {label}
              </button>
            </li>
          </ul>
        </div>
      </div>
    </>
  )
}
