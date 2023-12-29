import React, { useState, useRef } from 'react'
import CSRF from '../csrf.js'

export default function Following({ isFollowing, userId, isWatching }) {
  const [following, setFollowing] = useState(isFollowing)
  const [watching, setWatching] = useState(isWatching)
  const followingDetailsRef = useRef(null)

  const url = () => `/api/users/${userId}/followings`

  const followOrChangeFollow = (watch) => {
    const params = { watch: watch }
    fetch(url(), {
      method: following ? 'PATCH' : 'POST',
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': CSRF.getToken()
      },
      credentials: 'same-origin',
      redirect: 'manual',
      body: JSON.stringify(params)
    })
      .then((response) => {
        if (response.ok) {
          setFollowing(true)
          setWatching(watch)
        } else {
          alert('エラーが発生しました。')
        }
      })
      .catch((error) => {
        console.warn(error)
      })
      .finally(() => {
        followingDetailsRef.current.open = false
      })
  }

  const unfollow = () => {
    const params = { watch: watching }
    fetch(url(), {
      method: 'DELETE',
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': CSRF.getToken()
      },
      credentials: 'same-origin',
      redirect: 'manual',
      body: JSON.stringify(params)
    })
      .then((response) => {
        if (response.ok) {
          setFollowing(false)
          setWatching(false)
        } else {
          alert('エラーが発生しました。')
        }
      })
      .catch((error) => {
        console.warn(error)
      })
      .finally(() => {
        followingDetailsRef.current.open = false
      })
  }

  return (
    <details ref={followingDetailsRef} className="following">
      <summary className="following__summary">
        {following && watching ? (
          <span className="a-button is-warning is-sm is-block">
            <i className="fa-solid fa-check"></i>
            <span>コメントあり</span>
          </span>
        ) : following && !watching ? (
          <span className="a-button is-warning is-sm is-block">
            <i className="fa-solid fa-check"></i>
            <span>コメントなし</span>
          </span>
        ) : (
          <span className="a-button is-secondary is-sm is-block">
            フォローする
          </span>
        )}
      </summary>
      <div className="following__dropdown a-dropdown">
        <ul className="a-dropdown__items">
          <li className="following__dropdown-item a-dropdown__item">
            {following && watching ? (
              <button className="following-option a-dropdown__item-inner is-active">
                <div className="following-option__inner">
                  <div className="following-option__label">コメントあり</div>
                  <div className="following-option__desciption">
                    フォローしたユーザーの日報を自動でWatch状態にします。日報投稿時の通知と日報にコメントが来た際に通知を受け取ります。
                  </div>
                </div>
              </button>
            ) : (
              <button
                className="following-option a-dropdown__item-inner"
                onClick={() => followOrChangeFollow(true)}>
                <div className="following-option__inner">
                  <div className="following-option__label">コメントあり</div>
                  <div className="following-option__desciption">
                    フォローしたユーザーの日報を自動でWatch状態にします。日報投稿時の通知と日報にコメントが来た際に通知を受け取ります。
                  </div>
                </div>
              </button>
            )}
          </li>
          <li className="following__dropdown-item a-dropdown__item">
            {following && !watching ? (
              <button className="following-option a-dropdown__item-inner is-active">
                <div className="following-option__inner">
                  <div className="following-option__label">コメントなし</div>
                  <div className="following-option__desciption">
                    フォローしたユーザーの日報はWatch状態にしません。日報投稿時の通知だけ通知を受けとります。
                  </div>
                </div>
              </button>
            ) : (
              <button
                className="following-option a-dropdown__item-inner"
                onClick={() => followOrChangeFollow(false)}>
                <div className="following-option__inner">
                  <div className="following-option__label">コメントなし</div>
                  <div className="following-option__desciption">
                    フォローしたユーザーの日報はWatch状態にしません。日報投稿時の通知だけ通知を受けとります。
                  </div>
                </div>
              </button>
            )}
          </li>
          <li className="following__dropdown-item a-dropdown__item">
            <button
              className="following-option a-dropdown__item-inner"
              onClick={unfollow}>
              <div className="following-option__inner">
                <div className="following-option__label">フォローしない</div>
              </div>
            </button>
          </li>
        </ul>
      </div>
    </details>
  )
}
