import React from 'react'
import PropTypes from 'prop-types'

function Bookmark() {
  return (
    <div>
      <p>ブックマーク</p>
    </div>
    /*
      <div
        className={`card-list-item is-${this.props.bookmark.bookmarkable.model_name.to_s.toLowerCase()}`}>
        <div className="card-list-item__inner">
          {isTalk ? (
            <div className="card-list-item__user">
              {renderUserIcon({
                user: bookmark.bookmarkable.user,
                linkClass: 'card-list-item__user-link',
                imageClass: 'card-list-item__user-icon'
              })}
              <div className="card-list-item__rows">
                <div className="card-list-item__row">
                  <div className="card-list-item-title">
                    <h2 className="card-list-item-title__title">
                      <a
                        href={bookmark.bookmarkable}
                        className="card-list-item-title__link a-text-link">
                        {`${bookmark.bookmarkable.user.long_name} さんの相談部屋`}
                      </a>
                    </h2>
                  </div>
                </div>
              </div>
            </div>
          ) : (
            <div>
              <div className="card-list-item__label">
                {bookmark.bookmarkable.model_name.human}
              </div>
              <div className="card-list-item__rows">
                <div className="card-list-item__row">
                  <div className="card-list-item-title">
                    <h2 className="card-list-item-title__title">
                      <a
                        href={bookmark.bookmarkable}
                        className="card-list-item-title__link a-text-link">
                        {bookmark.bookmarkable.title}
                      </a>
                    </h2>
                  </div>
                </div>
                <div className="card-list-item__row">
                  <div className="card-list-item-meta">
                    <div className="card-list-item-meta__items">
                      <div className="card-list-item-meta__item">
                        <a
                          href={bookmark.bookmarkable.user}
                          className="a-user-name">
                          {bookmark.bookmarkable.user.long_name}
                        </a>
                      </div>
                      <div className="card-list-item-meta__item">
                        <time
                          className="a-meta"
                          dateTime={bookmark.reported_on_or_created_at}>
                          {l(bookmark.reported_on_or_created_at, {
                            format: 'long'
                          })}
                        </time>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          )}
          <div className="card-list-item__option js-bookmark-delete-button">
            <a
              href={current_user_bookmark_path(bookmark.id)}
              onClick={(e) => handleBookmarkDelete(e)}
              className="a-button is-sm is-primary">
              削除
            </a>
          </div>
        </div>
      </div>
    */
  )
}

Bookmark.propTypes = {
  user: PropTypes.object,
  bookmarks: PropTypes.array
}
export default Bookmark
