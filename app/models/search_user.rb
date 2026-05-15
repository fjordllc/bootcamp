# frozen_string_literal: true

class SearchUser
  def initialize(word:, users: nil, target: nil, require_retire_user: false)
    @users = users
    @word = word
    @target = target
    @require_retire_user = require_retire_user
  end

  def search
    validated_search_word = validate_search_word
    # 検索ワードが無効な場合は空の結果を返す
    return User.none if validated_search_word.nil?

    # Searcherを使ってユーザーを検索
    query_builder = Searcher::QueryBuilder.new(validated_search_word)
    config = Searcher::Configuration.get(:user)
    params = query_builder.build_params(config[:columns])

    searched_user = if @users
                      @users.ransack(params).result.includes(config[:includes]).distinct
                    else
                      User.ransack(params).result.includes(config[:includes]).distinct
                    end

    if @target == 'retired'
      searched_user.unscope(where: :retired_on).retired
    elsif @require_retire_user
      searched_user.unscope(where: :retired_on)
    else
      searched_user
    end
  end

  def validate_search_word
    return nil if @word.nil?

    stripped_word = @word.strip
    return nil if stripped_word.blank?

    stripped_word
  end
end
