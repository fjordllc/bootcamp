import React from 'react'
import UserIcon from './UserIcon'
import ProductChecker from './ProductChecker'

export default function Product({
  product,
  isMentor,
  currentUserId,
  elapsedDays
}) {
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
        <div className="card-list-item__user">
          <UserIcon user={product.user} blockClassSuffix="card-list-item" />
        </div>
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
      {isMentor && product.checks.size === 0 && (
        <div className="card-list-item__assignee is-only-mentor">
          <ProductChecker
            checkerId={product.checker_id}
            checkerName={product.checker_name}
            checkerAvatar={product.checker_avatar}
            currentUserId={currentUserId}
            productId={product.id}
            parentComponent="product"
          />
        </div>
      )}
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
  return (
    <div className="card-list-item__user-icons">
      {users.map((user) => (
        <a
          key={user.url}
          href={user.url}
          className="card-list-item__user-icons-icon">
          <img
            title={user.icon_title}
            alt={user.icon_title}
            src={user.avatar_url}
            className={`a-user-icon is-${user.primary_role}`}
          />
        </a>
      ))}
    </div>
  )
}

const LastCommentedTime = ({ product }) => {
  if (product.comments.size > 0) {
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
      return (
        <div className="a-meta">〜 {mentorLastCommentedAt}（メンター）</div>
      )
    }
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
