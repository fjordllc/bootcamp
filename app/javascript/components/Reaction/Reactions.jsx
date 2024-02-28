import React from 'react'
import { Reaction } from './Reaction'
import { ReactionDropdown } from './ReactionDropdown'
import { useReaction } from './useReaction'

const Reactions = ({
  reactionable,
  currentUser,
  reactionableId,
  availableEmojis,
  getKey,
}) => {
  const { handleCreateReaction, handleDeleteReaction } = useReaction(getKey, reactionableId)

  const displayedEmojis = reactionable.reaction_count.filter((el) => el.count !== 0)

  const clickedReaction = (kind) => reactionable.reaction.find(
    (el) => el.user_id === currentUser.id && el.kind === kind
  )

  const isReacted = (kind) => {
    const id = reactionable.reaction_count.findIndex((element) => element.kind === kind)
    const reaction = reactionable.reaction_count[id].login_names.filter(
      (el) => el === currentUser.login_name
    )
    return reaction.length !== 0
  }

  return (
    <div className="reactions test-block js-reactions">
      <ul className="reactions__items test-inline-block js-reaction">
        {displayedEmojis.map((emoji) => (
          <Reaction
            key={emoji.kind}
            emoji={emoji}
            isReacted={isReacted}
            clickedReaction={clickedReaction}
            onCreateReaction={handleCreateReaction}
            onDeleteReaction={handleDeleteReaction}
          />
        ))}
      </ul>
      <ReactionDropdown
        isReacted={isReacted}
        clickedReaction={clickedReaction}
        availableEmojis={availableEmojis}
        onCreateReaction={handleCreateReaction}
        onDeleteReaction={handleDeleteReaction}
      />
    </div>
  )
}

export default Reactions
