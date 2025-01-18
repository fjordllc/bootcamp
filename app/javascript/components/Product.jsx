import React, { useEffect, useRef } from 'react'
import userIcon from '../user-icon.js'
import ProductChecker from './ProductChecker'

export default function Product({
  product,
  isMentor,
  isAdmin,
  currentUserId,
  elapsedDays
}) {
  // userIconの非React化により、useRef,useEffectを導入している。
  const userIconRef = useRef(null)
  useEffect(() => {
    const linkClass = 'card-list-item__user-link'
    const imgClasses = ['card-list-item__user-icon', 'a-user-icon']

    const userIconElement = userIcon({
      user: product.user,
      linkClass,
      imgClasses
    })

    if (userIconRef.current) {
      userIconRef.current.innerHTML = ''
      userIconRef.current.appendChild(userIconElement)
    }
  }, [product.user])

  const notRespondedSign = () => {
    return (
      product.self_last_commented_at_date_time >
        product.mentor_last_commented_at_date_time ||
      product.comments.size === 0
    )
  }

  return (
    <div className="card-list-item has-assigned">
      <div className="card-list-item__inner">
        <div className="card-list-item__user" ref={userIconRef}></div>
        <div className="card-list-item__rows">
          <div className="card-list-item__row">
            <div className="card-list-item-title">
              {notRespondedSign() && (
                <div className="card-list-item__notresponded" />
              )}
              <div className="card-list-item-title__start">
                {product.wip && (
                  <div className="a-list-item-badge is-wip">
                    <span>WIP</span>
                  </div>
                )}
              </div>
              <h2 className="card-list-item-title__title" itemProp="name">
                <a
                  className="card-list-item-title__link a-text-link"
                  href={product.url}
                  itemProp="url">
                  {product.practice.title}の提出物
                </a>
              </h2>
            </div>
          </div>
          <div className="card-list-item__row">
            <div className="card-list-item-meta">
              <div className="card-list-item-meta__items">
                <div className="card-list-item-meta__item">
                  <a className="a-user-name" href={product.user.url}>
                    {product.user.long_name}
                  </a>
                </div>
              </div>
            </div>
          </div>
          <div className="card-list-item__row">
            <TimeInfo product={product} elapsedDays={elapsedDays} />
            <CommentInfo product={product} />
          </div>
          {(isMentor || isAdmin) && product.user.primary_role === 'trainee' && (
            <TrainingEndDateInfo product={product} />
          )}
          {isMentor && product.checks.size === 0 && (
            <div className="card-list-item__row is-only-mentor">
              <div className="card-list-item__assignee">
                <ProductChecker
                  checkerId={product.checker_id}
                  checkerName={product.checker_name}
                  checkerAvatar={product.checker_avatar}
                  currentUserId={currentUserId}
                  productId={product.id}
                />
              </div>
            </div>
          )}
        </div>
        {product.checks.size > 0 && (
          <div className=" stamp stamp-approve">
            <h2 className="stamp__content is-title">確認済</h2>
            <time className="stamp__content is-created-at">
              {product.checks.last_created_at}
            </time>
            <div className="stamp__content is-user-name">
              <div className="stamp__content-inner">
                {product.checks.last_user_login_name}
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  )
}

const TimeInfo = ({ product, elapsedDays }) => {
  const isDashboardPage = () => {
    return location.pathname === '/'
  }
  const isUnassignedPage = () => {
    return location.pathname === '/products/unassigned'
  }
  const untilNextElapsedDays = () => {
    const elapsedTimes = calcElapsedTimes(product)
    return Math.floor((Math.ceil(elapsedTimes) - elapsedTimes) * 24)
  }

  const calcElapsedTimes = () => {
    const time = product.published_at_date_time || product.created_at_date_time
    return (new Date() - Date.parse(time)) / 1000 / 60 / 60 / 24
  }

  if (product.wip) {
    return (
      <div className="card-list-item-meta">
        <div className="a-meta">提出物作成中</div>
      </div>
    )
  } else {
    return (
      <div className="card-list-item-meta">
        <div className="card-list-item__row">
          <div className="card-list-item-meta">
            <div className="card-list-item-meta__items">
              <div className="card-list-item-meta__item">
                <time className="a-meta" dateTime={product.created_at}>
                  <span className="a-meta__label">提出</span>
                  <span className="a-meta__value">{product.created_at}</span>
                </time>
              </div>
              <div className="card-list-item-meta__item">
                <time className="a-meta" dateTime={product.updated_at}>
                  <span className="a-meta__label">更新</span>
                  <span className="a-meta__value">{product.updated_at}</span>
                </time>
              </div>
              {(elapsedDays !== 7 && isUnassignedPage()) ||
              isDashboardPage() ? (
                <div className="card-list-item-meta__item">
                  <div className="a-meta">
                    {untilNextElapsedDays(product) < 1
                      ? `次の経過日数まで 1時間未満`
                      : `次の経過日数まで 約 ${untilNextElapsedDays(
                          product
                        )} 時間`}
                  </div>
                </div>
              ) : null}
            </div>
          </div>
        </div>
      </div>
    )
  }
}

const UserIcons = ({ users }) => {
  // userIconの非React化により、useRef,useEffectを導入している。
  const userIconRef = useRef(null)
  useEffect(() => {
    const linkClass = 'card-list-item__user-icons-icon'
    const imgClasses = ['a-user-icon']

    const userIconElements = users.map((user) => {
      return userIcon({
        user,
        linkClass,
        imgClasses
      })
    })

    if (userIconRef.current) {
      userIconRef.current.innerHTML = ''
      userIconElements.forEach((element) => {
        userIconRef.current.appendChild(element)
      })
    }
  }, [users])

  return <div className="card-list-item__user-icons" ref={userIconRef}></div>
}

const LastCommentedTime = ({ product }) => {
  const selfLastCommentedAt = product.self_last_commented_at
  const mentorLastCommentedAt = product.mentor_last_commented_at
  const selfLastCommentedAtDateTime = product.self_last_commented_at_date_time
  const mentorLastCommentedAtDateTime =
    product.mentor_last_commented_at_date_time

  if (selfLastCommentedAtDateTime && mentorLastCommentedAtDateTime) {
    if (selfLastCommentedAtDateTime > mentorLastCommentedAtDateTime) {
      return (
        <div className="a-meta">
          〜 {selfLastCommentedAt}（<strong>提出者</strong>）
        </div>
      )
    } else if (selfLastCommentedAtDateTime < mentorLastCommentedAtDateTime) {
      return (
        <div className="a-meta">〜 {mentorLastCommentedAt}（メンター）</div>
      )
    }
  } else if (selfLastCommentedAtDateTime) {
    return (
      <div className="a-meta">
        〜 {selfLastCommentedAt}（<strong>提出者</strong>）
      </div>
    )
  } else if (mentorLastCommentedAtDateTime) {
    return <div className="a-meta">〜 {mentorLastCommentedAt}（メンター）</div>
  }
  return null
}

const CommentInfo = ({ product }) => {
  return (
    <>
      {product.comments.size > 0 && (
        <hr className="card-list-item__row-separator" />
      )}
      {product.comments.size > 0 && (
        <div className="card-list-item-meta__items">
          <div className="card-list-item-meta__item">
            <div className="a-meta">コメント（{product.comments.size}）</div>
          </div>
          <div className="card-list-item-meta__item">
            <UserIcons users={product.comments.users} />
          </div>
          <div className="card-list-item-meta__item">
            <LastCommentedTime product={product} />
          </div>
        </div>
      )}
    </>
  )
}

const TrainingEndDateInfo = ({ product }) => {
  return (
    <div className="card-list-item__row">
      <div className="card-list-item-meta__items">
        <div className="card-list-item-meta__item">
          {product.user.training_ends_on ? (
            <time className="a-meta" dateTime={product.user.training_ends_on}>
              <span className="a-meta__label">研修終了日</span>
              <span className="a-meta__value">
                {product.user.training_ends_on}
              </span>
              {product.user.training_remaining_days === 0 ? (
                <span className="a-meta__value is-danger">
                  （本日研修最終日）
                </span>
              ) : product.user.training_remaining_days < 0 ? (
                <span className="a-meta__value">（研修終了）</span>
              ) : product.user.training_remaining_days < 7 ? (
                <span className="a-meta__value is-danger">
                  （あと{product.user.training_remaining_days}日）
                </span>
              ) : (
                <span className="a-meta__value">
                  （あと{product.user.training_remaining_days}日）
                </span>
              )}
            </time>
          ) : (
            <div className="a-meta">
              <span className="a-meta__label">研修終了日</span>
              <span className="a-meta__value">未入力</span>
            </div>
          )}
        </div>
      </div>
    </div>
  )
}
