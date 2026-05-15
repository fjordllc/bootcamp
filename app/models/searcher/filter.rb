# frozen_string_literal: true

class Searcher
  class Filter
    attr_reader :current_user, :only_me

    def initialize(current_user, only_me: false)
      @current_user = current_user
      @only_me = only_me
    end

    # 検索結果に各種フィルタを適用
    def apply(results)
      results = filter_by_visibility(results)
      results = filter_by_user(results) if only_me
      delete_private_comment!(results)
    end

    private

    # 各モデルのvisible_to_user?メソッドで可視性をチェックしてフィルタリング
    def filter_by_visibility(results)
      results.select { |record| visible_to_user?(record, current_user) }
    end

    # 現在のユーザーが投稿したコンテンツのみをフィルタリング
    def filter_by_user(results)
      results.select do |record|
        user_id = record.respond_to?(:search_user_id) ? record.search_user_id : record.try(:user_id)
        user_id == current_user.id
      end
    end

    # ユーザーに対するリソースの可視性をチェック
    def visible_to_user?(searchable, user)
      return searchable.visible_to_user?(user) if searchable.respond_to?(:visible_to_user?)

      [User, Practice, Page, Event, RegularEvent, Announcement, Report, Product, Question, Answer, CorrectAnswer].include?(searchable.class)
    end

    # 相談・問い合わせ系のプライベートコメントを検索結果から除外
    def delete_private_comment!(results)
      results.reject do |record|
        record.instance_of?(Comment) && record.commentable.class.in?([Talk, Inquiry, CorporateTrainingInquiry])
      end
    end
  end
end
