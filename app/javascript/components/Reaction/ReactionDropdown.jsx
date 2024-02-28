import React, { useState } from 'react'

export const ReactionDropdown = ({
  isReacted,
  clickedReaction,
  availableEmojis,
  onCreateReaction,
  onDeleteReaction
}) => {
  const [dropdown, setDropdown] = useState(false)

  return (
    <div className="reactions__dropdown js-reaction-dropdown">
      <button
        className="reactions__dropdown-toggle js-reaction-dropdown-toggle"
        onClick={() => setDropdown((dropdown) => !dropdown)}
      >
        <i className="fa-regular fa-plus reactions__dropdown-toggle-plus"></i>
        <i className="fa-solid fa-smile"></i>
      </button>
      <ul
        className="reactions__items test-inline-block js-reaction"
        style={{ display: dropdown ? 'block' : 'none' }}>
        {availableEmojis.map((emoji) => (
          <li
            key={emoji.kind}
            className={`reactions__item test-inline-block ${
              isReacted(emoji.kind) ? 'is-reacted' : ''
            }`}
            onClick={() => {
              if (isReacted(emoji.kind)) {
                const { id } = clickedReaction(emoji.kind)
                console.log(emoji, clickedReaction(emoji.kind))
                onDeleteReaction(id)
              } else {
                onCreateReaction(emoji.kind)
              }
              setDropdown(false)
            }}
            data-reaction-kind={emoji.kind}
          >
            <span className="reactions__item-emoji js-reaction-emoji">{emoji.value}</span>
          </li>
        ))}
      </ul>
    </div>
  )
}
