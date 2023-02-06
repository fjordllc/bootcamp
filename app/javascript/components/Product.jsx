import React from 'react'
import UserIcon from './UserIcon'

export default function Product({ product }) {
  return (
    <li className="card-list-item">
      <div className="card-list-item__inner">
        <div className="card-list-item__user">
          <UserIcon user={product.user} blockClassSuffix="card-list-item" />
        </div>
        <div className="card-list-item__rows">
          <div className="card-list-item__row">
            <div className="card-list-item-title">
              {product.wip && (
                <div className="a-list-item-badge is-wip">
                  <span>WIP</span>
                </div>
              )}
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
      </div>
    </li>
  )
}
