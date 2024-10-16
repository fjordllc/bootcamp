# frozen_string_literal: true

module ReactionsHelper
  def reactions_attributes(reactionable, user)
    {
      data: {
        reaction: {
          login: { name: user.login_name },
          reactionable: { id: dom_id(reactionable) }
        }
      }
    }
  end

  def reaction_attributes(reactionable, kind, user, only_reacted: true)
    attributes = { data: { reaction: { kind: } } }
    attributes[:hidden] = reactionable.reaction_count_by(kind).zero? if only_reacted
    reaction_id = reactionable.find_reaction_id_by(kind, user.login_name)

    if reaction_id
      attributes.deep_merge!(
        class: 'is-reacted',
        data: { reaction: { id: reaction_id } }
      )
    end

    attributes
  end

  def reaction_attributes_all(reactionable, kind, user)
    reaction_attributes(reactionable, kind, user, only_reacted: false)
  end
end
