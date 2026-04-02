# frozen_string_literal: true

class ReactionsReactionsComponentPreview < ViewComponent::Preview
  def default
    reactionable = mock_reactionable
    current_user = OpenStruct.new(
      id: 1,
      login_name: 'yamada'
    )

    render(Reactions::ReactionsComponent.new(
      reactionable: reactionable,
      current_user: current_user
    ))
  end

  def with_reactions
    reactionable = mock_reactionable(
      thumbsup: { count: 3, login_names: %w[tanaka suzuki sato] },
      heart: { count: 1, login_names: %w[tanaka] }
    )
    current_user = OpenStruct.new(
      id: 1,
      login_name: 'yamada'
    )

    render(Reactions::ReactionsComponent.new(
      reactionable: reactionable,
      current_user: current_user
    ))
  end

  private

  def mock_reactionable(reactions = {})
    OpenStruct.new(
      id: 1,
      class: OpenStruct.new(name: 'Report'),
      reaction_count_by: ->(kind) { reactions.dig(kind.to_sym, :count) || 0 },
      find_reaction_id_by: ->(_kind, _login_name) { nil },
      reaction_login_names_by: ->(kind) { reactions.dig(kind.to_sym, :login_names) || [] }
    )
  end
end
