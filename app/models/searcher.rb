# frozen_string_literal: true

class Searcher
  # 検索対象モデルの設定を集中管理
  SEARCH_CONFIGS = {
    practice: {
      model: Practice,
      columns: %i[title description goal],
      includes: [],
      label: 'プラクティス'
    },
    user: {
      model: User,
      columns: %i[login_name name name_kana twitter_account facebook_url blog_url github_account discord_profile_account_name description],
      includes: [],
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
    }
  }.freeze

  def self.available_types
    SEARCH_CONFIGS.keys
  end

  attr_reader :keyword, :document_type, :current_user, :only_me

  def initialize(keyword:, current_user:, document_type: :all, only_me: false)
    @keyword = keyword.to_s.strip
    @document_type = validate_document_type(document_type)
    @only_me = only_me
    @current_user = current_user
  end

  def search
    return [] if keyword.blank?

    results = if document_type == :all
                search_all_types
              else
                search_specific_type(document_type)
              end

    apply_filters(results)
  end

  private

  def search_all_types
    SEARCH_CONFIGS.flat_map do |_type, config|
      search_model(config)
    end
  end

  def search_specific_type(type)
    config = SEARCH_CONFIGS[type]
    return [] unless config

    results = search_model(config)

    # 特定のタイプの検索では、そのタイプに関連するコメントも含める
    if type != :comment
      comment_results = search_comments_for_type(type)
      results += comment_results
    end

    # questionタイプの場合はanswerとcorrect_answerも含める
    if type == :question
      answer_results = search_model(SEARCH_CONFIGS[:answer])
      correct_answer_results = search_model(SEARCH_CONFIGS[:correct_answer])
      results += answer_results + correct_answer_results
    end

    results
  end

  def search_model(config)
    model = config[:model]

    # Ransackを使ったLIKE検索
    ransack_params = build_ransack_params(config[:columns])
    search = model.ransack(ransack_params)

    # includesでN+1を防ぐ
    results = search.result(distinct: true)
    results = results.includes(*config[:includes]) if config[:includes].any?

    # デフォルトで更新日時の降順でソート
    results = results.order(updated_at: :desc)

    results.to_a
  end

  def build_ransack_params(columns)
    keywords = keyword.split(/[[:blank:]]+/).reject(&:blank?)

    if keywords.size == 1
      # 単一キーワード: OR検索
      { "#{columns.join('_or_')}_cont" => keywords.first }
    else
      # 複数キーワード: AND検索
      {
        g: keywords.map do |word|
          { "#{columns.join('_or_')}_cont" => word }
        end
      }
    end
  end

  def apply_filters(results)
    # 権限フィルタ
    results = filter_by_visibility(results)

    # 自分のもののみフィルタ
    results = filter_by_user(results) if only_me

    # プライベートコメントを除外
    results = delete_private_comment!(results)

    # 結果を統一フォーマットに変換
    results.map { |record| SearchResult.new(record, keyword, current_user) }
  end

  def filter_by_visibility(results)
    results.select { |record| visible_to_user?(record, current_user) }
  end

  def filter_by_user(results)
    classes_without_user_id = %w[Practice User]
    results
      .reject { |record| record.class.name.in?(classes_without_user_id) }
      .select { |record| record.user_id == current_user.id }
  end

  def visible_to_user?(searchable, user)
    case searchable
    when Talk
      user.admin? || searchable.user_id == user.id
    when Comment
      if searchable.commentable.is_a?(Talk)
        user.admin? || searchable.commentable.user_id == user.id
      else
        true
      end
    when User, Practice, Page, Event, RegularEvent, Announcement, Report, Product, Question, Answer
      true
    else
      false
    end
  end

  def delete_private_comment!(results)
    results.reject do |record|
      record.instance_of?(Comment) && record.commentable.class.in?([Talk, Inquiry, CorporateTrainingInquiry])
    end
  end

  def search_comments_for_type(type)
    config = SEARCH_CONFIGS[:comment]
    return [] unless config

    # コメントを検索
    comment_config = {
      model: config[:model],
      columns: config[:columns],
      includes: config[:includes]
    }

    comments = search_model(comment_config)

    # 指定されたタイプのコメンタブルに関連するコメントのみフィルタリング
    target_model = SEARCH_CONFIGS[type][:model]
    comments.select { |comment| comment.commentable_type == target_model.name }
  end

  def validate_document_type(document_type)
    type_sym = document_type&.to_sym || :all
    available_keys = SEARCH_CONFIGS.keys + [:all]
    return type_sym if available_keys.include?(type_sym)

    raise ArgumentError, "Invalid document_type: #{document_type}. Available types: #{available_keys.join(', ')}"
  end

  def self.available_types
    SEARCH_CONFIGS.keys
  end

  def self.available_types_for_select
    options = [['すべて', :all]]
    SEARCH_CONFIGS.each do |key, config|
      options << [config[:label], key]
    end
    options
  end
end
