# frozen_string_literal: true

require 'test_helper'

class SearchablesComponentTest < ViewComponent::TestCase
  def test_renders_search_results_when_searchables_are_present
    question = questions(:question1)
    user = users(:machida)
    users_hash = { user.id => user }
    talks_hash = {}
    word = 'エディター'

    render_inline(SearchablesComponent.new(
                    searchables: [question],
                    users: users_hash,
                    word:,
                    talks: talks_hash
                  ))

    assert_selector '.container.is-md'
    assert_selector '.card-list.a-card'
  end

  def test_renders_empty_message_when_no_searchables
    render_inline(SearchablesComponent.new(
                    searchables: [],
                    users: {},
                    word: 'テスト',
                    talks: {}
                  ))

    assert_selector '.o-empty-message'
    assert_selector '.o-empty-message__icon i.fa-regular.fa-sad-tear'
    assert_text 'テスト に一致する情報は見つかりませんでした。'
  end

  def test_renders_multiple_search_results
    question1 = questions(:question1)
    question2 = questions(:question2)
    user1 = users(:machida)
    user2 = users(:sotugyou)
    users_hash = { user1.id => user1, user2.id => user2 }
    talks_hash = {}
    word = 'テスト'

    render_inline(SearchablesComponent.new(
                    searchables: [question1, question2],
                    users: users_hash,
                    word:,
                    talks: talks_hash
                  ))

    assert_selector '.container.is-md'
    assert_selector '.card-list.a-card'
    # 2つのSearchableComponentが含まれることを確認
    assert_selector '.card-list-item', count: 2
  end
end
