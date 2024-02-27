import React, { useState, useCallback } from 'react'

const Reactions = ({
  // url,
  reactionable,
  currentUser,
  // reactionableId,
  availableEmojis
}) => {
  const [dropdown, setDropdown] = useState(false)
  const displayedEmojis = reactionable.reaction_count.filter((el) => el.count !== 0);

  const createReaction = async (_kind) => {}

  const destroyReaction = async (_kind) => {}

  const footerReaction = (kind) => {
    isReacted(kind) ? destroyReaction(kind) : createReaction(kind)
  }

  const dropdownToggle = useCallback(() => {
    setDropdown((dropdown) => !dropdown)
  }, [])

  const dropdownReaction = useCallback((kind) => {
    footerReaction(kind);
    dropdownToggle()
  }, [])

  const isReacted = (kind) => {
    const id = reactionable.reaction_count.findIndex((element) => element.kind === kind);
    const reaction = reactionable.reaction_count[id].login_names.filter(
      (el) => el === currentUser.login_name
    );
    return reaction.length !== 0
  }

  return (
    <div className="reactions test-block js-reactions">
      <ul className="reactions__items test-inline-block js-reaction">
        {displayedEmojis.map((emoji) => (
          <Reaction
            emoji={emoji}
            isReacted={isReacted}
            footerReaction={footerReaction}
          />
        ))}
      </ul>
      <ReactionDropdown
        dropdown={dropdown}
        dropdownToggle={dropdownToggle}
        dropdownReaction={dropdownReaction}
        isReacted={isReacted}
        availableEmojis={availableEmojis}
      />
    </div>
  )
}

const Reaction = ({ emoji, isReacted, footerReaction}) => {
  return (
    <li
      key={emoji.kind}
      className={`reactions__item test-inline-block ${
        isReacted(emoji.kind) ? 'is-reacted' : ''
      }`}
      onClick={() => footerReaction(emoji.kind)}
      data-reaction-kind={emoji.kind}
    >
      <span className="reactions__item-emoji js-reaction-emoji">{emoji.value}</span>
      <span className="reactions__item-count js-reaction-count">{emoji.count}</span>
      <ul className="reactions__item-login-names js-reaction-login-names">
        {emoji.loginNames.map((loginName) => (
          <li key={loginName}>{loginName}</li>
        ))}
      </ul>
    </li>
  )
}

const ReactionDropdown = ({
  dropdown,
  dropdownToggle,
  dropdownReaction,
  isReacted,
  availableEmojis
}) => {
  return (
    <div className="reactions__dropdown js-reaction-dropdown">
      <div
        className="reactions__dropdown-toggle js-reaction-dropdown-toggle"
        onClick={dropdownToggle}
      >
        <i className="fa-regular fa-plus reactions__dropdown-toggle-plus"></i>
        <i className="fa-solid fa-smile"></i>
      </div>
      <ul
        className="reactions__items test-inline-block js-reaction"
        style={{ display: dropdown ? 'block' : 'none' }}>
        {availableEmojis.map((emoji) => (
          <li
            key={emoji.kind}
            className={`reactions__item test-inline-block ${
              isReacted(emoji.kind) ? 'is-reacted' : ''
            }`}
            onClick={() => dropdownReaction(emoji.kind)}
            data-reaction-kind={emoji.kind}
          >
            <span className="reactions__item-emoji js-reaction-emoji">{emoji.value}</span>
          </li>
        ))}
      </ul>
    </div>
  )
}

export default Reactions
