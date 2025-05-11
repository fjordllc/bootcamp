import React from 'react'

export default function UserSns({ user }) {
  const githubUrl = `https://github.com/${user.github_account}`
  const twitterUrl = `https://twitter.com/${user.twitter_account}`

  return (
    <div className="sns-links">
      <ul className="sns-links__items is-button-group">
        <li className="sns-links__item">
          {user.github_account ? (
            <a
              className="sns-links__item-link a-button is-sm is-secondary is-icon"
              href={githubUrl}>
              <i className="fa-brands fa-github-alt"></i>
            </a>
          ) : (
            <div className="sns-links__item-link a-button is-sm is-disabled is-icon">
              <i className="fa-brands fa-github-alt"></i>
            </div>
          )}
        </li>
        <li className="sns-links__item">
          {user.twitter_account ? (
            <a
              className="sns-links__item-link a-button is-sm is-secondary is-icon"
              href={twitterUrl}>
              <i className="fa-brands fa-x-twitter"></i>
            </a>
          ) : (
            <div className="sns-links__item-link a-button is-sm is-disabled is-icon">
              <i className="fa-brands fa-x-twitter"></i>
            </div>
          )}
        </li>
        <li className="sns-links__item">
          {user.facebook_url ? (
            <a
              className="sns-links__item-link a-button is-sm is-secondary is-icon"
              href={user.facebook_url}>
              <i className="fa-brands fa-facebook-square"></i>
            </a>
          ) : (
            <div className="sns-links__item-link a-button is-sm is-disabled is-icon">
              <i className="fa-brands fa-facebook-square"></i>
            </div>
          )}
        </li>
        <li className="sns-links__item">
          {user.blog_url ? (
            <a
              className="sns-links__item-link a-button is-sm is-secondary is-icon"
              href={user.blog_url}>
              <i className="fa-solid fa-blog"></i>
            </a>
          ) : (
            <div className="sns-links__item-link a-button is-sm is-disabled is-icon">
              <i className="fa-solid fa-blog"></i>
            </div>
          )}
        </li>
        <li className="sns-links__item">
          {user.discord_profile.times_url ? (
            <a
              className="sns-links__item-link a-button is-sm is-secondary is-icon"
              href={user.discord_profile.times_url}>
              <i className="fa-solid fa-clock"></i>
            </a>
          ) : (
            <div className="sns-links__item-link a-button is-sm is-disabled is-icon">
              <i className="fa-solid fa-clock"></i>
            </div>
          )}
        </li>
      </ul>
      {user.company && user.company.logo_url && (
        <a href={user.company.url}>
          <img
            className="user-item__company-logo-image"
            src={user.company.logo_url}
          />
        </a>
      )}
    </div>
  )
}
