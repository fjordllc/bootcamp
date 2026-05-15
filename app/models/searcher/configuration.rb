# frozen_string_literal: true

class Searcher
  module Configuration
    CONFIGS = {
      practice: {
        model: Practice,
        columns: %i[title description goal],
        includes: [],
        label: 'プラクティス'
      },
      user: {
        model: User,
        columns: %i[login_name name name_kana twitter_account facebook_url blog_url github_account description discord_profile_account_name],
        includes: [:discord_profile],
        label: 'ユーザー'
      },
      report: {
        model: Report,
        columns: %i[title description],
        includes: [:user],
        label: '日報'
      },
      product: {
        model: Product,
        columns: %i[body],
        includes: %i[user practice],
        label: '提出物'
      },
      announcement: {
        model: Announcement,
        columns: %i[title description],
        includes: [:user],
        label: 'お知らせ'
      },
      page: {
        model: Page,
        columns: %i[title body],
        includes: [:user],
        label: 'Docs'
      },
      question: {
        model: Question,
        columns: %i[title description],
        includes: [:user],
        label: 'Q&A'
      },
      answer: {
        model: Answer,
        columns: %i[description],
        includes: %i[user question],
        label: '回答'
      },
      correct_answer: {
        model: CorrectAnswer,
        columns: %i[description],
        includes: %i[user question],
        label: '模範回答'
      },
      comment: {
        model: Comment,
        columns: %i[description],
        includes: %i[user commentable],
        label: 'コメント'
      },
      event: {
        model: Event,
        columns: %i[title description],
        includes: [:user],
        label: 'イベント'
      },
      regular_event: {
        model: RegularEvent,
        columns: %i[title description],
        includes: [:user],
        label: '定期イベント'
      },
      pair_work: {
        model: PairWork,
        columns: %i[title description],
        includes: [:user],
        label: 'ペアワーク'
      }
    }.freeze

    def self.configurations
      CONFIGS
    end

    def self.get(type)
      CONFIGS[type]
    end

    def self.available_types
      CONFIGS.keys
    end

    def self.available_types_for_select
      options = [['すべて', :all]]
      configurations.each do |key, config|
        options << [config[:label], key]
      end
      options
    end
  end
end
