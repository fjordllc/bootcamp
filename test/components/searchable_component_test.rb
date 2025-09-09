# frozen_string_literal: true

require 'test_helper'

class SearchableComponentTest < ViewComponent::TestCase
  def setup
    @question = questions(:question1)
    @user = users(:machida)
    @users_hash = { @user.id => @user }
    @talks_hash = {}
    @word = 'エディター'
  end

  def test_renders_question_search_result
    render_inline(SearchableComponent.new(
                    resource: @question,
                    users: @users_hash,
                    word: @word,
                    talks: @talks_hash
                  ))

    assert_selector '.card-list-item.is-question'
    assert_selector '.card-list-item-title__link', text: @question.title
    # questionの場合はバッジは表示されない
    assert_no_selector '.a-list-item-badge'
  end

  def test_renders_user_search_result
    user = users(:kimura)
    users_hash = { user.id => user }

    render_inline(SearchableComponent.new(
                    resource: user,
                    users: users_hash,
                    word: @word,
                    talks: @talks_hash
                  ))

    assert_selector '.card-list-item.is-user'
    assert_selector '.card-list-item__user'
    assert_selector '.card-list-item-title__link', text: user.login_name
    assert_selector '.a-list-item-badge.is-searchable', text: 'ユーザー'
    assert_selector "img[src*='#{user.avatar_url}']"
  end

  def test_renders_wip_product_search_result
    product = products(:product5)
    user = users(:hajime)
    users_hash = { user.id => user }

    render_inline(SearchableComponent.new(
                    resource: product,
                    users: users_hash,
                    word: @word,
                    talks: @talks_hash
                  ))

    assert_selector '.card-list-item.is-product'
    assert_selector '.a-list-item-badge.is-wip', text: 'WIP'
  end

  def test_renders_comment_search_result
    comment = comments(:comment1)
    user = users(:komagata)
    users_hash = { user.id => user }

    render_inline(SearchableComponent.new(
                    resource: comment,
                    users: users_hash,
                    word: @word,
                    talks: @talks_hash
                  ))

    assert_selector '.card-list-item.is-comment'
    assert_selector '.a-list-item-badge.is-searchable', text: 'コメント'
  end

  def test_renders_answer_search_result
    answer = answers(:answer1)
    user = users(:komagata)
    users_hash = { user.id => user }

    render_inline(SearchableComponent.new(
                    resource: answer,
                    users: users_hash,
                    word: @word,
                    talks: @talks_hash
                  ))

    assert_selector '.card-list-item.is-answer'
    assert_selector '.a-list-item-badge.is-searchable', text: 'コメント'
  end

  def test_does_not_render_talk_search_result
    # talk リソースはunlessブロックでスキップされる
    talk = OpenStruct.new(search_model_name: 'talk', search_user_id: @user.id)

    render_inline(SearchableComponent.new(
                    resource: talk,
                    users: @users_hash,
                    word: @word,
                    talks: @talks_hash
                  ))

    # talk の場合は何も出力されない
    assert_no_selector '.card-list-item'
  end

  def test_renders_user_meta_information_for_non_user_resources
    render_inline(SearchableComponent.new(
                    resource: @question,
                    users: @users_hash,
                    word: @word,
                    talks: @talks_hash
                  ))

    assert_selector '.card-list-item-meta__user'
    assert_selector "img[src*='#{@user.avatar_url}']"
    assert_selector '.a-user-name', text: @user.login_name
  end

  def test_does_not_render_user_meta_for_user_resources
    user = users(:kimura)
    users_hash = { user.id => user }

    render_inline(SearchableComponent.new(
                    resource: user,
                    users: users_hash,
                    word: @word,
                    talks: @talks_hash
                  ))

    # ユーザーリソースの場合はメタ情報にユーザー情報は表示されない
    assert_no_selector '.card-list-item-meta__user'
  end

  def test_renders_updated_time
    render_inline(SearchableComponent.new(
                    resource: @question,
                    users: @users_hash,
                    word: @word,
                    talks: @talks_hash
                  ))

    assert_selector '.card-list-item-meta__item time'
  end

  def test_renders_search_label_for_non_user_resources
    render_inline(SearchableComponent.new(
                    resource: @question,
                    users: @users_hash,
                    word: @word,
                    talks: @talks_hash
                  ))

    assert_selector '.card-list-item__label'
    assert_text @question.search_label
  end

  def test_does_not_render_search_label_for_user_resources
    user = users(:kimura)
    users_hash = { user.id => user }

    render_inline(SearchableComponent.new(
                    resource: user,
                    users: users_hash,
                    word: @word,
                    talks: @talks_hash
                  ))

    assert_no_selector '.card-list-item__label'
  end

  def test_resource_user_method_returns_correct_user
    component = SearchableComponent.new(
      resource: @question,
      users: @users_hash,
      word: @word,
      talks: @talks_hash
    )

    assert_equal @user, component.resource_user
  end

  def test_talk_method_returns_correct_talk
    talk = talks(:talk1)
    talks_hash = { @user.id => talk }

    component = SearchableComponent.new(
      resource: @question,
      users: @users_hash,
      word: @word,
      talks: talks_hash
    )

    assert_equal talk, component.talk
  end

  def test_talk_method_returns_nil_when_no_resource_user
    users_hash = {}
    component = SearchableComponent.new(
      resource: @question,
      users: users_hash,
      word: @word,
      talks: @talks_hash
    )

    assert_nil component.talk
  end

  def test_comment_meta_info_returns_formatted_string_for_comment
    comment = comments(:comment1)
    user = users(:komagata)
    users_hash = { user.id => user }

    component = SearchableComponent.new(
      resource: comment,
      users: users_hash,
      word: @word,
      talks: @talks_hash
    )

    result = component.comment_meta_info
    assert result.present?
    # HTMLが含まれるかテスト
    assert_includes result, 'a-user-name'
  end

  def test_comment_meta_info_returns_nil_for_non_comment
    component = SearchableComponent.new(
      resource: @question,
      users: @users_hash,
      word: @word,
      talks: @talks_hash
    )

    assert_nil component.comment_meta_info
  end

  def test_answer_meta_info_returns_formatted_string_for_answer
    answer = answers(:answer1)
    user = users(:komagata)
    users_hash = { user.id => user }

    component = SearchableComponent.new(
      resource: answer,
      users: users_hash,
      word: @word,
      talks: @talks_hash
    )

    result = component.answer_meta_info
    assert result.present?
    # HTMLエスケープされた文字列が含まれるかテスト
    assert_includes result, 'Q&amp;A'
  end

  def test_answer_meta_info_returns_nil_for_non_answer
    component = SearchableComponent.new(
      resource: @question,
      users: @users_hash,
      word: @word,
      talks: @talks_hash
    )

    assert_nil component.answer_meta_info
  end

  def test_search_title_text_returns_search_title_when_present
    component = SearchableComponent.new(
      resource: @question,
      users: @users_hash,
      word: @word,
      talks: @talks_hash
    )

    assert_equal @question.title, component.search_title_text
  end

  def test_search_title_text_returns_login_name_when_search_title_blank
    user = users(:kimura)
    users_hash = { user.id => user }

    component = SearchableComponent.new(
      resource: user,
      users: users_hash,
      word: @word,
      talks: @talks_hash
    )

    assert_equal user.login_name, component.search_title_text
  end
end
