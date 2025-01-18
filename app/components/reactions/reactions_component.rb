# frozen_string_literal: true

class Reactions::ReactionsComponent < ViewComponent::Base
  def initialize(reactionable:, current_user:)
    @reactionable = reactionable
    @current_user = current_user
  end

  def reactions_attributes
    {
      data: {
        reaction: {
          login: { name: @current_user.login_name },
          reactionable: { id: dom_id(@reactionable) }
        }
      }
    }
  end

  def reaction_attributes(kind, only_reacted: true)
    attributes = { data: { reaction: { kind: } } }
    attributes[:hidden] = @reactionable.reaction_count_by(kind).zero? if only_reacted
    reaction_id = @reactionable.find_reaction_id_by(kind, @current_user.login_name)

    if reaction_id
      attributes.deep_merge!(
        class: 'is-reacted',
        data: { reaction: { id: reaction_id } }
      )
    end

    attributes
  end

  def reaction_attribute(kind)
    reaction_attributes(kind, only_reacted: false)
  end
end
