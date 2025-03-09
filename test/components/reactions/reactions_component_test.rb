# frozen_string_literal: true

require 'test_helper'

class Reactions::ReactionsComponentTest < ViewComponent::TestCase
  def setup
    @current_user = users(:machida)
    @reacted_comment = comments(:comment2)
    render_inline(Reactions::ReactionsComponent.new(reactionable: @reacted_comment, current_user: @current_user))
  end

  def test_reactions_attributes
    assert_selector ".js-reactions[data-reaction-login-name='#{@current_user.login_name}']"
    assert_selector ".js-reactions[data-reaction-reactionable-id='comment_#{@reacted_comment.id}']"
  end

  def test_display_reaction
    current_user_heart_reaction = reactions(:reaction3)
    assert_selector ".is-reacted[data-reaction-kind='heart']" \
                    "[data-reaction-id='#{current_user_heart_reaction.id}']" do
      assert_selector '.reactions__item-emoji.js-reaction-emoji', text: '❤️'
      assert_selector '.reactions__item-count.js-reaction-count', text: '2'
      assert_selector '.reactions__item-login-names.js-reaction-login-names li', text: 'komagata'
      assert_selector '.reactions__item-login-names.js-reaction-login-names li', text: 'machida'
    end

    other_user_thumbsup_reaction = reactions(:reaction5)
    assert_no_selector ".reactions_item.is-reacted[data-reaction-kind='thumbsup']" \
                       "[data-reaction-id='#{other_user_thumbsup_reaction.id}']"
    assert_selector ".reactions__item[data-reaction-kind='thumbsup']" do
      assert_selector '.reactions__item-emoji.js-reaction-emoji', text: '👍'
      assert_selector '.reactions__item-count.js-reaction-count', text: '1'
      assert_selector '.reactions__item-login-names.js-reaction-login-names li', text: 'komagata'
    end
  end

  def test_does_not_display_unreacted_emojis
    unreacted_emojis = Reaction.emojis.except('heart', 'thumbsup')
    unreacted_emojis.each_key do |kind|
      assert_selector ".reactions__item[data-reaction-kind='#{kind}']", visible: false
    end
  end

  def test_render_reaction_dropdown
    current_user_heart_reaction = reactions(:reaction3)
    reacted_emojis = Reaction.emojis.slice('heart')
    unreacted_emojis = Reaction.emojis.except('heart')

    assert_selector '.js-reaction-dropdown' do
      assert_selector '.reactions__dropdown-toggle'
      reacted_emojis.each do |kind, emoji|
        assert_selector ".reactions__item.is-reacted[data-reaction-kind='#{kind}']" \
                        "[data-reaction-id='#{current_user_heart_reaction.id}']", visible: false do
          assert_selector '.reactions__item-emoji.js-reaction-emoji', text: emoji, visible: false
        end
      end

      unreacted_emojis.each do |kind, emoji|
        assert_selector ".reactions__item[data-reaction-kind='#{kind}']", visible: false do
          assert_selector '.reactions__item-emoji.js-reaction-emoji', text: emoji, visible: false
        end
      end
    end
  end
end
