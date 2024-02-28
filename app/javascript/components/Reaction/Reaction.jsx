import React from 'react'

export const Reaction = ({
  emoji,
  isReacted,
  clickedReaction,
  onCreateReaction,
  onDeleteReaction
}) => {
  const { id: reactionId } = clickedReaction(emoji.kind)

  return (
    <li
      key={emoji.kind}
      className={`reactions__item test-inline-block ${
        isReacted(emoji.kind) ? 'is-reacted' : ''
      }`}
      onClick={() => isReacted(emoji.kind) ? onDeleteReaction(reactionId) : onCreateReaction(emoji.kind)}
      data-reaction-kind={emoji.kind}
    >
      <span className="reactions__item-emoji js-reaction-emoji">{emoji.value}</span>
      <span className="reactions__item-count js-reaction-count">{emoji.count}</span>
      <ul className="reactions__item-login-names js-reaction-login-names">
        {emoji.login_names.map((loginName) => (
          <li key={loginName}>{loginName}</li>
        ))}
      </ul>
    </li>
  )
}
