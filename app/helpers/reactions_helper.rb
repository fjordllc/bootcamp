# frozen_string_literal: true

module ReactionsHelper
  def reaction_attributes(kind, reactionable, only_reacted: true)
    attributes = { data: { reaction: { kind: kind } } }
    attributes[:hidden] = reactionable.reacted_count(kind).zero? if only_reacted
    reacted_id = reactionable.reacted_id(current_user, kind)

    if reacted_id
      attributes.deep_merge!(
        class: "is-reacted",
        data: { reaction: { id: reacted_id } }
      )
    end

    attributes
  end

  def reaction_attributes_all(kind, reactionable)
    reaction_attributes(kind, reactionable, only_reacted: false)
  end
end
