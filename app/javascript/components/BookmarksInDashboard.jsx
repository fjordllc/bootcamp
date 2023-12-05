import React from 'react'
import PropTypes from 'prop-types'
class BookmarksInDashboard extends React.Component {
  render() {
    return (
      <div className="a-card">
        <header className="card-header is-sm">
          <h2 className="card-header__title">最新のブックマーク</h2>
          <div className="card-header__action">
            <label className="a-form-label is-sm is-inline">編集</label>
            <label className="a-on-off-checkbox is-sm spec-bookmark-edit">
              <input id="bookmark_edit" type="checkbox" />
              <span></span>
            </label>
          </div>
        </header>
        {/*
        <hr className="a-border-tint" />
        <div className="card-list">
          {bookmarks.map((bookmark) => (
            <Bookmark key={bookmark.id} {...bookmark} />
          ))}
        </div> */}
        <p>ユーザーの名前：{this.props.user.login_name}</p>
        <footer className="card-footer">
          <div className="card-footer__footer-link">
            <a
              href="current_user/bookmarks"
              className="card-footer__footer-text-link">
              全てのブックマーク（{this.props.bookmarks.length}）
            </a>
          </div>
        </footer>
      </div>
    )
  }
}

BookmarksInDashboard.propTypes = {
  user: PropTypes.object,
  bookmarks: PropTypes.integer
}
export default BookmarksInDashboard
