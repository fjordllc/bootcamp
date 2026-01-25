# frozen_string_literal: true

require 'application_system_test_case'

class Admin::EmbeddingStatusTest < ApplicationSystemTestCase
  test 'admin can view embedding status page' do
    visit_with_auth admin_embedding_status_index_path, 'komagata'
    assert_text 'Embedding進捗'
    assert_text '全体進捗'
  end

  test 'non-admin cannot view embedding status page' do
    visit_with_auth admin_embedding_status_index_path, 'kimura'
    assert_text '管理者としてログインしてください'
  end

  test 'displays job management link' do
    visit_with_auth admin_embedding_status_index_path, 'komagata'
    assert_selector 'a[href="/jobs"]', text: 'ジョブ管理'
  end

  test 'displays help commands' do
    visit_with_auth admin_embedding_status_index_path, 'komagata'
    assert_text 'rails smart_search:generate_all'
    assert_text 'rails smart_search:stats'
  end

  test 'navigation tab is displayed and active' do
    visit_with_auth admin_embedding_status_index_path, 'komagata'
    assert_selector '.page-tabs__item-link.is-active', text: 'Embedding'
  end
end
