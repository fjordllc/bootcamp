# frozen_string_literal: true

require 'test_helper'

class SearchResultsTest < ActionDispatch::IntegrationTest
  USER_ICON = 'img.card-list-item-meta__icon.a-user-icon'

  test 'shows matched word in bold' do
    search('komagata', '検索ワードが太字で表示されるかのテスト')
    assert_select 'strong.matched_word', text: '検索ワードが太字で表示されるかのテスト'
  end

  test 'searches with document type' do
    search('hatsuno', '検索結果テスト用', :report)
    labels = css_select('.card-list-item__label').map { |label| label.text.strip }
    assert_equal ['日報'], labels
  end

  test 'searches events and regular events' do
    %w[テストのイベント 定期イベントの検索結果テスト用].each do |word|
      search('hatsuno', word, :event)
      assert_includes results_text, word
    end
  end

  test 'shows user icon, name and updated time in report' do
    search('hatsuno', 'テストの日報', :report)
    assert_includes results_text, 'mentormentaro'
    assert_select '.a-meta'
    assert_select USER_ICON
    assert_not_includes results_text, 'テストの回答'
  end

  %w[komagata advijirou kimura hatsuno].each do |login_name|
    test "#{login_name} can see results of comment" do
      search(login_name, 'テストの日報')
      assert_includes results_text, 'テストの日報'
    end
  end

  test 'shows document author name when comment' do
    search('hatsuno', '提出物のコメントです。')
    assert_includes results_text, 'komagata'
    assert_includes results_text, 'kimura'
    assert_not_includes results_text, 'machida'
  end

  test 'searches user' do
    search('hatsuno', 'komagata', :user)
    assert_select '.card-list-item'
    assert_includes results_text, 'komagata'
    assert_not_includes results_text, 'PC性能の見方を知る'
  end

  test 'searches user with nil description' do
    users(:kimura).update_attribute(:description, nil) # rubocop:disable Rails/SkipsModelValidations
    search('hatsuno', 'kimura', :user)
    assert_select '.card-list-item'
    assert_includes results_text, 'kimura'
  end

  test 'shows link to consultation room only to administrator' do
    search('hatsuno', 'komagata', :user)
    assert_includes results_text, 'komagata'
    assert_not_includes results_text, '相談部屋'

    search('komagata', 'komagata', :user)
    assert_includes results_text, '相談部屋'
  end

  test 'returns no results for empty keyword' do
    search('komagata', '', :user)
    assert_select '.o-empty-message'
    assert_includes response.body, 'に一致する情報は見つかりませんでした。'
  end

  test 'does not show icon in results of user' do
    search('hatsuno', 'hajime', :user)
    assert_select '.card-list-item'
    assert_select USER_ICON, count: 0
  end

  %i[all user].each do |document_type|
    %w[yameo kyuukai].each do |login_name|
      test "search with #{document_type} scope includes #{login_name}" do
        search('hatsuno', login_name, document_type)
        assert_includes css_select('.card-list-item.is-user').text, login_name
      end
    end
  end

  test 'responds with bad request to unknown document type' do
    post user_sessions_path, params: { user: { login: 'hatsuno', password: 'testtest' } }
    get searchables_path, params: { document_type: 'pages', word: 'テスト' }
    assert_response :bad_request
  end

  test 'responds with bad request to document type given as array' do
    post user_sessions_path, params: { user: { login: 'hatsuno', password: 'testtest' } }
    get searchables_path, params: { document_type: ['pages'], word: 'テスト' }
    assert_response :bad_request
  end

  test 'responds with bad request to document type given as hash' do
    post user_sessions_path, params: { user: { login: 'hatsuno', password: 'testtest' } }
    get searchables_path, params: { document_type: { name: 'report' }, word: 'テスト' }
    assert_response :bad_request
  end

  private

  def search(login_name, word, document_type = :all)
    post user_sessions_path, params: { user: { login: login_name, password: 'testtest' } }
    get searchables_path, params: { document_type:, word: }
    assert_response :success
  end

  def results_text
    css_select('.page-body').text
  end
end
