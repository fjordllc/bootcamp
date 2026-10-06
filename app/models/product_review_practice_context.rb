# frozen_string_literal: true

# Practice context comes from practice relationships, independently of submission sources.
class ProductReviewPracticeContext
  MAX_DOCS = 20
  DOC_BODY_LIMIT = 20_000
  TOTAL_BODY_LIMIT = 100_000

  def initialize(practice)
    @practice = practice
  end

  def to_h
    {
      practice_title: @practice.title,
      practice_description: @practice.description,
      practice_goal: @practice.goal
    }.merge(docs_context)
  end

  private

  def docs_context
    published = Page.for_practice_including_source(@practice).where(wip: false)
    docs = []
    remaining = TOTAL_BODY_LIMIT
    published.order(:id).limit(MAX_DOCS).pluck(:id, :title, :body).each do |id, title, body|
      break if remaining.zero?

      doc = bounded_doc(id, title, body, remaining)
      docs << doc
      remaining -= doc[:body].length
    end
    context = { practice_docs: docs }
    omitted_count = published.count - docs.size
    context[:practice_docs_omission] = "上限（#{MAX_DOCS}件・本文合計#{TOTAL_BODY_LIMIT}文字）により#{omitted_count}件のDocを省略しました。省略した本文は未確認です。" if omitted_count.positive?
    context
  end

  def bounded_doc(id, title, body, remaining)
    excerpt = body.slice(0, [DOC_BODY_LIMIT, remaining].min)
    doc = { id:, title:, body: excerpt }
    doc[:truncation] = "切り詰め: 本文の先頭#{excerpt.length}文字のみ。残りは未確認です。" if excerpt.length < body.length
    doc
  end
end
