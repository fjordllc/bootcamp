# frozen_string_literal: true

class SearchablesController < ApplicationController
  PER_PAGE = 50

  def index
    @word = params[:word].to_s
    @document_type = params[:document_type]&.to_sym || :all
    page = (params[:page] || 1).to_i
    per_page = PER_PAGE

    search_results, total_count = Searcher.search(
      word: @word,
      only_me: params[:only_me],
      document_type: @document_type,
      current_user:,
      page: page,
      per_page: per_page
    )

    @searchables = Kaminari.paginate_array(search_results, total_count: total_count).page(page).per(per_page)

    user_ids = @searchables.map(&:user_id).compact.uniq
    @users_by_id = User.where(id: user_ids).index_by(&:id)
    @talks_by_user_id = Talk.where(user_id: user_ids).index_by(&:user_id)
  end
end
