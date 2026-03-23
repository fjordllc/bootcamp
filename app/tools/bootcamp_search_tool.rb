# frozen_string_literal: true

class BootcampSearchTool < RubyLLM::Tool
  description 'bootcampのプラクティス（カリキュラム）、ドキュメント（Docs）、Q&A、お知らせを検索する。' \
              'ユーザーの質問に答えるために必要な情報を探すときに使う。'

  param :query, desc: '検索キーワード（日本語または英語）'
  param :category, type: :string, desc: '検索カテゴリ（practice, page, question, announcement, all）', required: false

  # 検索対象とカラムの定義
  SEARCH_TARGETS = {
    practice: { model: 'Practice', columns: %i[title description goal], label: 'プラクティス' },
    page: { model: 'Page', columns: %i[title body], label: 'Docs' },
    question: { model: 'Question', columns: %i[title description], label: 'Q&A' },
    announcement: { model: 'Announcement', columns: %i[title description], label: 'お知らせ' }
  }.freeze

  RESULT_LIMIT = 5
  CONTENT_TRUNCATE_LENGTH = 500

  def execute(query:, category: 'all')
    targets = select_targets(category)
    results = search(query, targets)

    return '検索結果が見つかりませんでした。別のキーワードで試してみてください。' if results.empty?

    format_results(results)
  end

  private

  def select_targets(category)
    key = category&.to_sym
    if key && key != :all && SEARCH_TARGETS.key?(key)
      { key => SEARCH_TARGETS[key] }
    else
      SEARCH_TARGETS
    end
  end

  def search(query, targets)
    keywords = query.to_s.split(/[[:blank:]]+/).reject(&:blank?)
    return [] if keywords.empty?

    targets.flat_map do |_type, config|
      search_model(config, keywords)
    end.first(RESULT_LIMIT)
  end

  def search_model(config, keywords)
    model = config[:model].constantize
    columns = config[:columns]

    scope = model.all
    keywords.each do |word|
      escaped = word.gsub(/[\\%_]/) { |c| "\\#{c}" }
      conditions = columns.map { |col| model.arel_table[col].matches("%#{escaped}%", nil, true) }
      scope = scope.where(conditions.reduce(:or))
    end
    scope.distinct.order(updated_at: :desc).limit(RESULT_LIMIT).to_a
  end

  def format_results(results)
    results.map { |record| format_record(record) }.join("\n\n---\n\n")
  end

  def format_record(record)
    title = record.try(:title) || record.class.model_name.human
    content = extract_content(record)
    url = build_url(record)
    label = SEARCH_TARGETS.values.find { |t| t[:model] == record.class.name }&.dig(:label) || record.class.model_name.human

    parts = ["**[#{label}] #{title}**"]
    parts << content if content.present?
    parts << "URL: #{url}" if url.present?
    parts.join("\n")
  end

  def extract_content(record)
    text = record.try(:description) || record.try(:body) || ''
    text.truncate(CONTENT_TRUNCATE_LENGTH)
  end

  def build_url(record)
    Rails.application.routes.url_helpers.polymorphic_path(record)
  rescue ActionController::UrlGenerationError, NoMethodError
    nil
  end
end
