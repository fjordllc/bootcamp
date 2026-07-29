# frozen_string_literal: true

class AiPrompt < ApplicationRecord
  DEFINITIONS = {
    'article_meta_description' => {
      name: '記事のmeta description生成',
      description: '記事本文から検索結果などに表示する概要文を生成します。',
      path: 'article_meta_description_agent/instructions.txt'
    },
    'pjord' => {
      name: 'ピヨルド共通',
      description: 'ピヨルドがすべての応答で共通して守る役割や振る舞いを定めます。',
      path: 'pjord/agent/instructions.txt'
    },
    'mention_response' => {
      name: 'メンション返信',
      description: 'ユーザーからピヨルドへのメンションに返信する方針を定めます。',
      path: 'pjord/mention_response_agent/instructions.txt'
    },
    'product_review' => {
      name: '提出物レビュー',
      description: '提出物をレビューし、コメントを作成する方針を定めます。',
      path: 'pjord/product_review_agent/instructions.txt'
    },
    'question_answer' => {
      name: 'Q&A回答',
      description: 'Q&Aに投稿された質問へ回答する方針を定めます。',
      path: 'pjord/question_answer_agent/instructions.txt'
    },
    'report_classifier' => {
      name: '日報分類',
      description: '日報の内容から、コメントの意図を分類する方針を定めます。',
      path: 'pjord/report_classifier_agent/instructions.txt'
    },
    'report_comment' => {
      name: '日報コメント',
      description: '分類された意図に沿って日報へのコメントを作成する方針を定めます。',
      path: 'pjord/report_comment_agent/instructions.txt'
    }
  }.freeze

  validates :key, presence: true, inclusion: { in: DEFINITIONS.keys }, uniqueness: true
  validates :body, presence: true

  class << self
    def definitions
      DEFINITIONS
    end

    def body_for(key)
      key = key.to_s
      find_by(key:)&.body || default_body_for(key)
    end

    def default_body_for(key)
      definition = DEFINITIONS.fetch(key.to_s)
      Rails.root.join('app/prompts', definition.fetch(:path)).read
    end
  end
end
