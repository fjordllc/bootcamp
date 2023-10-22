import React from 'react'
import UserIcon from './UserIcon'
import ProductChecker from './ProductChecker'

export default function Product({ product, isMentor, currentUserId }) {
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
            <a className="a-user-name" href={product.user.url}>
              {product.user.login_name}
            </a>
          </div>
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
              </div>
            </div>
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
