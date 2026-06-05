# frozen_string_literal: true

require 'ruby_llm/schema'

class PjordProductReviewResponse < RubyLLM::Schema
  description 'ピヨルドが提出物に対して作成するレビューコメント'

  array :reviewed_points,
        of: :string,
        min_items: 1,
        description: '提出物本文、URL先の内容、模範解答、過去コメントなどを確認して判断した具体的な点'

  string :body,
         min_length: 1,
         description: 'ユーザーにそのまま見せるレビューコメント本文。検索やツール使用などの内部手順説明は含めない。'
end
