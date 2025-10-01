# frozen_string_literal: true

module ReactionHelper
  def add_reaction(kind)
    find('.js-reaction-dropdown-toggle').click
    find(".js-reaction-dropdown li[data-reaction-kind='#{kind}']").click
  end

  def open_reaction_users_list
    find('.js-reactions-users-toggle').click
  end

  def clear_reactions_for(reactionable)
    reactionable.reactions.destroy_all
  end
end
