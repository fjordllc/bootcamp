import React, { useState } from 'react'
import toast from '../../toast'
import CSRF from "../../csrf";

export default function TagEditModal({ tagId, propTagName, setShowModal }) {
  const initialTagName = propTagName
  const [tagName, setTagName] = useState(propTagName)

  const validation = tagName === initialTagName || tagName === ''

  const changeTagName = (e) => {
    setTagName(e.target.value)
  }

  const closeModal = () => {
    setShowModal(false)
    setTagName(initialTagName)
  }

  const updateTagList = () => {
    toast.methods.toast('タグ名を変更しました')
    // 変更した内容を反映するためにリクエストを送り直している。
    // 変更内容を反映したい箇所がslimで書かれているためである。
    location.href = location.pathname.replace(
            `/tags/${encodeURIComponent(initialTagName)}`,
            `/tags/${encodeURIComponent(tagName)}`
          )
  }

  const updateTag = () => {
    if (tagName === '' || tagName === initialTagName) {
      return null
    }

    const params = {
      tag: { name: tagName }
    }

    fetch(`/api/tags/${tagId}`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': CSRF.getToken()
      },
      credentials: 'same-origin',
      redirect: 'manual',
      body: JSON.stringify(params)
    })
      .then(() => {
        closeModal()
        updateTagList()
      })
      .catch((error) => {
        console.warn(error)
      })
  }

  return (
    <div className="a-overlay is-vue">
      <div className="a-card is-modal">
        <header className="card-header is-sm">
          <h2 className="card-header__title">タグ名変更</h2>
        </header>
        <div className="card-body">
          <div className="card__description">
            <label className="a-form-label" htmlFor="tag_name">
              タグ名
            </label>
            <input
              id="tag_name"
              className="a-text-input"
              value={tagName}
              onChange={changeTagName}
              name="tag[name]"
            />
          </div>
        </div>
        <footer className="card-footer">
          <div className="card-main-actions">
            <ul className="card-main-actions__items">
              <li className="card-main-actions__item is-main">
                <button
                  className="a-button is-primary is-sm is-block"
                  disabled={validation}
                  onClick={updateTag}>
                  変更
                </button>
              </li>
              <li className="card-main-actions__item is-sub">
                <div
                  className="card-main-actions__muted-action"
                  onClick={closeModal}>
                  キャンセル
                </div>
              </li>
            </ul>
          </div>
        </footer>
      </div>
    </div>
  )
}
