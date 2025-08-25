# frozen_string_literal: true

class Searcher
  DOCUMENT_TYPES = [
    ['すべて', :all], ['お知らせ', :announcements], ['プラクティス', :practices],
    ['日報', :reports], ['提出物', :products], ['Q&A', :questions],
    ['Docs', :pages], ['イベント', :events], ['定期イベント', :regular_events],
    ['ユーザー', :users]
  ].freeze

  AVAILABLE_TYPES = DOCUMENT_TYPES.map(&:second) - %i[all] + %i[comments answers correct_answers]
  class SearchRow
    attr_reader :id, :record_type, :title, :body, :description, :user_id,
                :updated_at, :wip, :commentable_type, :commentable_id

    def initialize(h)
      @id = h['id']
      @record_type = h['record_type']
      @title = h['title']
      @body  = h['body']
      @description = h['description']
      @user_id = h['user_id']
      @updated_at = h['updated_at'].is_a?(String) ? Time.zone.parse(h['updated_at']) : h['updated_at']
      @wip = h['wip']
      @commentable_type = h['commentable_type']
      @commentable_id   = h['commentable_id']
    end

    def class
      OpenStruct.new(name: record_type.classify)
    end

    def try(sym)
      send(sym) if respond_to?(sym)
    end

    def model_name
      OpenStruct.new(name: record_type.classify)
    end

    def label
      case record_type
      when 'regular_events' then "定期\nイベント"
      when 'events' then "特別\nイベント"
      when 'practices' then "プラク\nティス"
      when 'answers', 'correct_answers' then 'Q&A'
      when 'comments' then 'コメント'
      else
        I18n.t("activerecord.models.#{record_type.singularize}", default: record_type)
      end
    end

    def comment_label
      return 'コメント' if commentable_type.blank?

      case commentable_type
      when 'Announcement' then 'お知らせ'
      when 'Practice' then "プラク\nティス"
      when 'Report' then '日報'
      when 'Product' then '提出物'
      when 'Question' then 'Q&A'
      when 'Page' then 'Docs'
      when 'Event' then "特別\nイベント"
      when 'RegularEvent' then "定期\nイベント"
      else 'コメント'
      end
    end

    def formatted_updated_at
      weekdays = %w[日 月 火 水 木 金 土]
      updated_at.strftime("%Y年%m月%d日(#{weekdays[updated_at.wday]}) %H:%M")
    end

    def commentable
      return nil unless commentable_type.present? && commentable_id.present?

      klass = commentable_type.safe_constantize
      return nil unless klass

      case klass.name
      when 'Product'
        Product.where(id: commentable_id).preload(:practice).first
      else
        klass.find_by(id: commentable_id)
      end
    rescue StandardError
      nil
    end
  end

  class << self
    include SearchHelper

    def search(word:, current_user:, only_me: false, document_type: :all, page: nil, all: false)
      words = word.split(/[[:blank:]]+/).reject(&:blank?)

      return union_search(words:, current_user:, only_me:, document_type:, page:, all:) if document_type == :all || union_target?(document_type)

      searchables = fetch_results(words, document_type).select { |s| visible_to_user?(s, current_user) }
      users_by_id = preload_users_for(searchables)

      delete_private_comment!(searchables).map { |s| SearchResult.new(s, word, current_user, users_by_id:) }
    end

    private

    def union_target?(type)
      %i[
        announcements practices reports products questions answers
        pages events regular_events comments
      ].include?(type)
    end

    def union_search(words:, current_user:, only_me:, document_type:, page: nil, all: false)
      current_page = (page.presence || 1).to_i
      per_page = if all
                   10_000
                 else
                   begin
                     SearchablesController::PER_PAGE
                   rescue StandardError
                     Kaminari.config.default_per_page || 50
                   end
                 end
      offset = (current_page - 1).clamp(0, 10_000) * per_page

      q = UnifiedSearchQuery.new(
        words:,
        document_type:,
        only_me:,
        current_user_id: current_user.id
      )

      rows = ActiveRecord::Base.connection.exec_query(q.page_sql(limit: per_page, offset:)).to_a
      total = ActiveRecord::Base.connection.select_value(q.count_sql).to_i

      stubs = rows.map { |r| SearchRow.new(r) }
      users_by_id = preload_users_for(stubs)

      results = stubs.map do |stub|
        SearchResult.new(stub, words.join(' '), current_user, users_by_id:)
      end

      Kaminari.paginate_array(results, total_count: total).page(current_page).per(per_page)
    end

    def filter_only_searchable(searchables, current_user)
      searchables.select do |s|
        case s
        when User then false
        when Practice then s.last_updated_user_id == current_user.id
        else s.respond_to?(:user_id) && s.user_id == current_user.id
        end
      end
    end

    def fetch_results(words, document_type)
      return results_for_all(words) if document_type == :all

      model(document_type)
      return result_for_questions(document_type, words) if document_type == :questions

      base_results = result_for(document_type, words).to_a
      comment_results = comments_for(document_type, words) || []

      (base_results + comment_results).uniq.sort_by(&:updated_at).reverse
    end

    def results_for_all(words)
      if (user_filter = extract_user_filter(words))
        content_words = words.reject { |w| w.start_with?('user:') }
        return search_by_user_filter(user_filter, content_words)
      end

      results = AVAILABLE_TYPES.flat_map { |type| result_for(type, words).to_a }
      users = search_users(words).to_a
      (results + users).uniq.sort_by(&:updated_at).reverse
    end

    def result_for(type, words)
      raise ArgumentError, "#{type} is not available" unless type.in?(AVAILABLE_TYPES)
      return search_users(words) if type == :users

      klass = model(type)

      base_scope = if type == :comments
                     klass.where.not(commentable_type: 'Talk')
                   else
                     klass.all
                   end

      return base_scope if words.blank?

      apply_word_filters(base_scope, klass, words).order(updated_at: :desc)
    end

    def result_for_comments(document_type, words)
      (result_for(document_type, words).to_a + comments_for(document_type, words))
        .sort_by(&:updated_at).reverse
    end

    def result_for_questions(document_type, words)
      (result_for(document_type, words).to_a + result_for(:answers, words).to_a + result_for(:correct_answers, words).to_a)
        .sort_by(&:updated_at).reverse
    end

    def apply_word_filters(query, klass, words)
      words.reduce(query) do |q, word|
        word.start_with?('user:') ? apply_user_filter(q, klass, word) : apply_column_filter(q, klass, word)
      end
    end

    def apply_user_filter(query, klass, word)
      user = User.find_by(login_name: word.delete_prefix('user:'))
      return query.none unless user

      column =
        if klass == Practice
          :last_updated_user_id
        elsif klass.column_names.include?('user_id')
          :user_id
        end

      column ? query.where(column => user.id) : query.none
    end

    def apply_column_filter(query, klass, word)
      cols = klass.column_names & %w[title body description]
      return query if cols.empty?

      query.where(cols.map { |c| "#{c} ILIKE :word" }.join(' OR '), word: "%#{word}%")
    end

    def comments_for(document_type, words)
      all_comments = result_for(:comments, words) || []
      return all_comments if document_type == :all

      all_comments.select { |c| c.commentable_type == search_model_name(document_type) }
    end

    def filter_only_me(searchables, current_user)
      searchables.select do |s|
        case s
        when User
          false
        when Practice
          s.last_updated_user_id == current_user.id
        else
          s.respond_to?(:user_id) && s.user_id == current_user.id
        end
      end
    end

    def load_users_for(searchables)
      ids = searchables.map { |s| s.try(:user_id) }.compact.uniq
      return {} if ids.empty?

      User.with_attached_avatar.where(id: ids).index_by(&:id)
    end

    def load_commentable_owners_for(searchables)
      result = {}
      commentables_by_type = Hash.new { |h, k| h[k] = [] }
      searchables.each do |s|
        next unless s.is_a?(Comment)

        commentables_by_type[s.commentable_type] << s.commentable_id
      end

      commentables_by_type.each do |type_name, ids|
        klass = type_name.safe_constantize
        next unless klass&.column_names&.include?('user_id')

        klass.where(id: ids.uniq).pluck(:id, :user_id).each do |id, uid|
          result[:"#{type_name}_#{id}"] = uid
        end
      end

      question_ids = searchables.select { |s| s.is_a?(Answer) || s.is_a?(CorrectAnswer) }
                                .map { |a| a.try(:question_id) }.compact.uniq
      if question_ids.any?
        Question.where(id: question_ids).pluck(:id, :user_id).each do |id, uid|
          result[:"Question_#{id}"] = uid
        end
      end

      result
    end

    def model(type) = search_model_name(type)&.constantize
    def extract_user_filter(words) = words.find { |w| w.match(/^user:(\w+)$/) }&.delete_prefix('user:')

    def search_by_user_filter(username, words)
      user = User.find_by(login_name: username) or return []
      filter_by_keywords(search_by_user_id(user.id), words)
    end

    def search_by_user_id(user_id)
      AVAILABLE_TYPES.reject { |t| t == :users }.flat_map do |t|
        model(t).where(user_filter_condition(t, user_id)).to_a
      end
    end

    def user_filter_condition(type, user_id)
      type == :practices ? { last_updated_user_id: user_id } : { user_id: }
    end

    def search_users(words)
      User.where(
        words.map { |_w| 'login_name ILIKE ? OR name ILIKE ? OR description ILIKE ?' }.join(' AND '),
        *words.flat_map { |w| ["%#{w}%"] * 3 }
      )
    end

    def delete_private_comment!(searchables)
      (searchables || []).reject do |s|
        s.instance_of?(Comment) && s.commentable.class.in?([Talk, Inquiry, CorporateTrainingInquiry])
      end
    end

    def preload_users_for(searchables)
      ids = searchables.map { |s| s.try(:user_id) }.compact.uniq
      return {} if ids.empty?

      User.where(id: ids).index_by(&:id)
    end
  end
end
