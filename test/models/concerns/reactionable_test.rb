# frozen_string_literal: true

require 'test_helper'

class ReactionableTest < ActiveSupport::TestCase
  test 'reaction methods return the same results without queries when reactions are preloaded' do
    report = reports(:report1)
    preloaded_report = Report.preload(reactions: :user).find(report.id)
    kinds = Reaction.kinds.keys

    assert_operator report.reactions.count, :>, 1
    expected = kinds.index_with { |kind| reaction_summary(report, kind) }

    assert_no_queries do
      assert_equal(expected, kinds.index_with { |kind| reaction_summary(preloaded_report, kind) })
    end
  end

  private

  def reaction_summary(reactionable, kind)
    [
      reactionable.reaction_count_by(kind),
      reactionable.reaction_login_names_by(kind),
      reactionable.find_reaction_id_by(kind, 'machida')
    ]
  end
end
