# frozen_string_literal: true

module SearchHelper
  include ActionView::Helpers::SanitizeHelper
  include ERB::Util
  include MarkdownHelper
  include PolicyHelper

  EXTRACTING_CHARACTERS = 50

  # コメントや回答の検索結果に対して実際のドキュメントを返す
  # コメントの場合：コメント先のオブジェクト（日報、提出物など）
  # 回答の場合：関連する質問、その他の場合：リソース自体
  def matched_document(searchable)
    if searchable.instance_of?(Comment)
      searchable.commentable_type.constantize.find(searchable.commentable_id)
    elsif searchable.instance_of?(Answer) || searchable.instance_of?(CorrectAnswer)
      searchable.question
    else
      searchable
    end
  end

  # 検索可能リソースから権限チェック付きでコンテンツを抽出・フィルタリング
  # 提出物コメントのプラクティス修了要件などの特殊ケースを処理
  # convert_markdown: trueの場合Markdown変換済みテキスト、falseの場合生コンテンツを返す
  def filtered_message(searchable, convert_markdown: true)
    content = extract_filtered_content(searchable)
    convert_markdown ? md2plain_text(content) : content
  end

  # リソースコンテンツからキーワードマッチをハイライトしたテキスト要約を生成
  # 権限に基づいてコンテンツをフィルタリングし、関連するテキストスニペットを抽出
  # テーブル形式などの特殊ケースも処理
  def search_summary(resource, keyword)
    content = filtered_message(resource, convert_markdown: false)
    return '' if content.nil? || content.blank?

    return process_special_case(content, keyword) if content.is_a?(String) && content.include?('|') && !content.include?('```')

    plain_content = md2plain_text(content)
    result = find_match_in_text(plain_content, keyword)
    result || ''
  end

  # キーワードハイライト付きのHTML形式検索要約を返す
  # マッチした単語をスタイリング用のCSSクラス付き<strong>タグで囲む
  def formatted_search_summary(resource, keyword)
    summary_text = search_summary(resource, keyword)
    highlight_word(summary_text, keyword)
  end

  private

  # 権限フィルタリング付きでリソースから生コンテンツを抽出する内部メソッド
  def extract_filtered_content(resource)
    if resource.is_a?(Comment) && resource.commentable_type == 'Product'
      commentable = resource.commentable
      return '該当プラクティスを修了するまで他の人の提出物へのコメントは見れません。' unless policy(commentable).show? || commentable.practice.open_product?

      return resource.description
    end

    # 基本的なコンテンツ抽出はSearchableのメソッドを使用
    resource.search_content
  end

  # マッチしたキーワードをハイライト用のHTML <strong>タグで囲む
  # セキュリティのためHTMLエスケープと出力のサニタイズを実行
  def highlight_word(text, word)
    return text unless text.present? && word.present?

    escaped_text = ERB::Util.html_escape(text)
    words = Searcher.split_keywords(word)
    highlighted_text = words.reduce(escaped_text) do |text_fragment, w|
      text_fragment.gsub(/(#{Regexp.escape(w)})/i, '<strong class="matched_word">\1</strong>')
    end

    ActionController::Base.helpers.sanitize(highlighted_text, tags: %w[strong], attributes: %w[class])
  end

  # パイプ文字を含むテーブルコンテンツなどの特殊フォーマットケースを処理
  # 処理前にMarkdownをプレーンテキストに変換
  def process_special_case(comment, word)
    summary = md2plain_text(comment)
    find_match_in_text(summary, word)
  end

  # テキスト内でキーワードマッチを検索し、周辺のコンテキストを抽出
  # 最初のキーワードマッチを中心としたテキストスニペットを返す
  def find_match_in_text(text, word)
    return text[0, EXTRACTING_CHARACTERS * 2] if word.blank?

    words = Searcher.split_keywords(word)
    first_match_position = nil

    words.each do |w|
      position = text.downcase.index(w.downcase)
      first_match_position = position if position && (first_match_position.nil? || position < first_match_position)
    end

    if first_match_position
      start_pos = [0, first_match_position - EXTRACTING_CHARACTERS].max
      end_pos = [text.length, first_match_position + EXTRACTING_CHARACTERS].min
      text[start_pos...end_pos].strip
    else
      text[0, EXTRACTING_CHARACTERS * 2]
    end
  end
end
