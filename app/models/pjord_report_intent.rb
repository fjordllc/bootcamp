# frozen_string_literal: true

require 'ruby_llm/schema'

class PjordReportIntent < RubyLLM::Schema
  INTENTS = %w[question struggling celebration none].freeze

  description '日報の内容から、ピヨルドがどんなコメントをすべきかを分類した結果'

  string :intent,
         enum: INTENTS,
         description: <<~DESC
           日報に対してピヨルドが取るべき対応の種類。
           - question: 質問・疑問・詰まっている記述がある。アドバイスが必要
           - struggling: 落ち込み・焦り・疲労・挫折感などネガティブな感情が表れている。励ましが必要
           - celebration: 大きな達成・ブレイクスルー・喜びが表れている。祝福が必要
           - none: 上記いずれにも当てはまらない通常の学習記録。コメント不要
         DESC
  string :reason, description: 'その分類にした理由（日本語、1〜2文）'
end
