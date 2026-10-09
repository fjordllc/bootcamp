# frozen_string_literal: true

require 'test_helper'

class ProductsHelperTest < ActionView::TestCase
  test '#product_category_practices_link_path' do
    def current_user = users(:kimura)

    category = products(:product8).category(current_user.course)

    assert_equal(
      course_practices_path(current_user.course, anchor: "category-#{category.id}"),
      product_category_practices_link_path(category)
    )
  end

  test 'unconfirmed_links_label returns correct label for all targets' do
    assert_equal '全ての提出物を一括で開く', unconfirmed_links_label('all')
    assert_equal '未完了の提出物を一括で開く', unconfirmed_links_label('unchecked')
    assert_equal '未完了の提出物を一括で開く', unconfirmed_links_label('unchecked_all')
    assert_equal '未返信の提出物を一括で開く', unconfirmed_links_label('unchecked_no_replied')
    assert_equal '未アサインの提出物を一括で開く', unconfirmed_links_label('unassigned')
    assert_equal '自分の担当の提出物を一括で開く', unconfirmed_links_label('self_assigned')
    assert_equal '自分の担当の提出物を一括で開く', unconfirmed_links_label('self_assigned_all')
    assert_equal '未返信の担当の提出物を一括で開く', unconfirmed_links_label('self_assigned_no_replied')
  end

  test 'unconfirmed_links_label returns empty string for unknown target' do
    assert_equal '', unconfirmed_links_label('unknown')
    assert_equal '', unconfirmed_links_label(nil)
  end

  test 'AI review separates older reply from later support while preserving raw Markdown' do
    before = "## 良い点\n良い点です。\n\n"
    reply = "\n提出物の作成おつかれさまです。\n\n### 確認したいこと\n[リンク](https://example.com) と **強調**\n\n```ruby\nputs 1\n```\n\n"
    after = "## 不確実な点\nメンターが確認する内容。\n"
    content = "#{before}## 受講生への返信案\n#{reply}#{after}"

    assert_equal({ body: before + after, reply: reply }, product_ai_review_sections(content))
    assert_equal "#{before}## 受講生への返信案\n#{reply}#{after}", content
  end

  test 'AI review ignores reply headings inside fenced code and nested containers' do
    content = "## 良い点\n\n```markdown\n## 受講生への返信案\n偽の返信\n```\n\n> ## 受講生への返信案\n> 引用の返信\n"

    assert_equal({ body: content, reply: nil }, product_ai_review_sections(content))
  end

  test 'AI review leaves absent or empty reply unchanged' do
    ["## 良い点\n本文\n", "## 受講生への返信案\n \n\n## 不確実な点\n本文\n"].each do |content|
      assert_equal({ body: content, reply: nil }, product_ai_review_sections(content))
    end
  end

  test 'AI review supports setext reply headings and ends at a higher level heading' do
    before = "良い点\n======\n本文\n\n"
    reply = "\n提出物の作成おつかれさまです。\n\n### 質問\n問いかけ\n\n"
    after = "不確実な点\n======\n確認内容\n"
    content = "#{before}受講生への返信案\n--------------\n#{reply}#{after}"

    assert_equal({ body: before + after, reply: reply }, product_ai_review_sections(content))
  end

  test 'AI review unwraps only a sole outer reply blockquote preserving inner Markdown' do
    reply = "\n> 提出物の作成おつかれさまです。\n>\n> - **良い点** と [リンク](https://example.com)\n>\n> > 引用は残す\n>\n> ```ruby\n> puts '> code'\n> ```\n\n"
    expected = "\n提出物の作成おつかれさまです。\n\n- **良い点** と [リンク](https://example.com)\n\n> 引用は残す\n\n```ruby\nputs '> code'\n```\n\n"
    content = "## 良い点\n本文\n\n## 受講生への返信案\n#{reply}"

    assert_equal expected, product_ai_review_sections(content)[:reply]
  end

  test 'AI review keeps intentional quotes alongside other top-level reply content' do
    reply = "提出物の作成おつかれさまです。\n\n> 意図的な引用\n\n[リンク](https://example.com)\n"
    content = "## 受講生への返信案\n#{reply}"

    assert_equal reply, product_ai_review_sections(content)[:reply]
  end
end
