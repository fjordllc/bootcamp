# frozen_string_literal: true

require 'test_helper'

class ProductReviewPracticeContextTest < ActiveSupport::TestCase
  setup do
    @practice = practices(:practice2)
    @practice.pages.each { |page| page.update!(practice: nil) }
    @practice.update!(source_id: nil)
  end

  test 'includes practice fields and published current and immediate source Docs in id order' do
    source = practices(:practice3)
    ancestor = practices(:practice4)
    source.pages.each { |page| page.update!(practice: nil) }
    source.update!(source_practice: ancestor)
    @practice.update!(source_practice: source)
    current_doc = create_doc(body: '現在の課題資料')
    source_doc = create_doc(practice: source, body: '複製元の課題資料')
    create_doc(wip: true, body: '非公開の下書き')
    create_doc(practice: source, wip: true, body: '複製元の下書き')
    create_doc(practice: ancestor, body: '複製元のさらに複製元')
    create_doc(practice: practices(:practice5), body: '別の課題資料')
    create_doc(practice: nil, body: '関連のない資料')

    context = ProductReviewPracticeContext.new(@practice).to_h

    assert_equal @practice.title, context[:practice_title]
    assert_equal @practice.description, context[:practice_description]
    assert_equal @practice.goal, context[:practice_goal]
    assert_equal [current_doc.id, source_doc.id].sort, context[:practice_docs].pluck(:id)
    assert_equal [current_doc, source_doc].sort_by(&:id).map { |doc| { id: doc.id, title: doc.title, body: doc.body } }, context[:practice_docs]
    assert_nil context[:practice_docs_omission]
  end

  test 'preserves raw Markdown code and tables without following any practice links' do
    body = <<~MARKDOWN
      整数は0以上を受け付けます。

      ```ruby
      valid = value >= 0 && value < 10
      ```

      | 入力 | 結果 |
      | --- | --- |
      | 0 | 有効 |

      [追加資料](https://example.com/doc-child)
      ![図](https://example.com/doc-child.png)
    MARKDOWN
    doc = create_doc(body:)
    @practice.description = 'https://example.com/practice'
    @practice.goal = 'https://bootcamp.fjord.jp/pages/315'

    context = ProductReviewPracticeContext.new(@practice).to_h

    assert_equal({ id: doc.id, title: doc.title, body: }, context[:practice_docs].sole)
    assert_not_requested :get, /example.com|bootcamp.fjord.jp/
  end

  test 'returns an empty list when the practice has no published Docs' do
    create_doc(wip: true)

    context = ProductReviewPracticeContext.new(@practice).to_h

    assert_empty context[:practice_docs]
    assert_nil context[:practice_docs_omission]
  end

  test 'includes only twenty Docs and explicitly reports omitted Docs' do
    docs = Array.new(22) { create_doc }

    context = ProductReviewPracticeContext.new(@practice).to_h

    assert_equal docs.first(20).map(&:id), context[:practice_docs].pluck(:id)
    assert_includes context[:practice_docs_omission], '2件'
    assert_includes context[:practice_docs_omission], '未確認'
  end

  test 'caps each Doc body at twenty thousand characters and marks truncation' do
    create_doc(body: "#{'界' * 20_000}UNSEEN_DOC_TAIL")

    context = ProductReviewPracticeContext.new(@practice).to_h
    doc = context[:practice_docs].sole

    assert_equal '界' * 20_000, doc[:body]
    assert_includes doc[:truncation], '切り詰め'
    assert_includes doc[:truncation], '未確認'
    assert_nil context[:practice_docs_omission]
  end

  test 'caps aggregate body characters and reports partial and omitted Docs' do
    docs = Array.new(7) { create_doc(body: '界' * 19_000) }

    context = ProductReviewPracticeContext.new(@practice).to_h
    included = context[:practice_docs]

    assert_equal docs.first(6).map(&:id), included.pluck(:id)
    assert_equal(100_000, included.sum { |doc| doc[:body].length })
    assert_equal '界' * 5000, included.last[:body]
    assert_includes included.last[:truncation], '未確認'
    assert_includes context[:practice_docs_omission], '1件'
    assert_includes context[:practice_docs_omission], '未確認'
  end

  test 'exact body limits do not falsely mark complete Docs as truncated' do
    Array.new(5) { create_doc(body: '界' * 20_000) }

    context = ProductReviewPracticeContext.new(@practice).to_h

    assert_equal 5, context[:practice_docs].size
    assert(context[:practice_docs].none? { |doc| doc.key?(:truncation) })
    assert_nil context[:practice_docs_omission]
  end

  private

  def create_doc(practice: @practice, body: '架空の資料本文', wip: false)
    Page.create!(practice:, user: users(:komagata), title: '架空の教材Doc', body:, wip:)
  end
end
