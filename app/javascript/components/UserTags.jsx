import React from 'react'

export default function UserTags({ user }) {
  const tags = user.tag_list

  if (tags.length === 0) {
    return null
  }

  return (
    <div className="tag-links">
      <ul className="tag-links__items">
        {tags.map((tag) => (
          <li className="tag-links__item" key={tag}>
            <a
              className="tag-links__item-link"
              href={`/users/tags/${encodeURIComponent(tag)}`}>
              {tag}
            </a>
          </li>
        ))}
      </ul>
    </div>
  )
}
