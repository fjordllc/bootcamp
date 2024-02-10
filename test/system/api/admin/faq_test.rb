# frozen_string_literal: true

require 'application_system_test_case'

class API::Admin::FaqTest < ApplicationSystemTestCase
  test 'sort FAQ' do
    visit faq_path
    assert_equal all('h3.faqs-item__title').first.text, '学習を終えるのにどれくらいの時間がかかりますか？'
    assert_equal all('h3.faqs-item__title').last.text, 'フィヨルドブートキャンプを利用していることを誰にも知られたくないのですが、匿名で参加はできますか？'

    visit_with_auth admin_faqs_path, 'komagata'
    source = all('.js-grab.a-grab').first
    target = all('.js-grab.a-grab').last
    source.drag_to(target)

    visit faq_path
    assert_equal all('h3.faqs-item__title').last.text, '学習を終えるのにどれくらいの時間がかかりますか？'
  end

  test "doesn't affect the order of other FAQs" do
    visit faq_path
    assert_equal all('h3.faqs-item__title')[0].text, '学習を終えるのにどれくらいの時間がかかりますか？'
    assert_equal all('h3.faqs-item__title')[1].text, '途中で辞めることは可能ですか？'

    visit_with_auth admin_faqs_path, 'komagata'
    source = all('.js-grab')[7] # faq8
    target = all('.js-grab')[9] # faq10
    source.drag_to(target)

    visit faq_path
    assert_equal all('h3.faqs-item__title')[0].text, '学習を終えるのにどれくらいの時間がかかりますか？'
    assert_equal all('h3.faqs-item__title')[1].text, '途中で辞めることは可能ですか？'
  end
end
