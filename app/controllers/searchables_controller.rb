# frozen_string_literal: true

class SearchablesController < ApplicationController
  PER_PAGE = 50

  def index
    @word = params[:word].to_s
    @document_type = params[:document_type]&.to_sym || :all

    searcher = Searcher.new(
      keyword: params[:word],
      document_type: params[:document_type],
      only_me: params[:only_me].present?,
      current_user:
    )
    results = searcher.search
    @searchables = Kaminari.paginate_array(results).page(params[:page]).per(PER_PAGE)

    user_ids = @searchables.map(&:search_user_id).compact.uniq
    @users = User.where(id: user_ids).index_by(&:id)
    @talks = Talk.where(user_id: user_ids).index_by(&:user_id)
  end
end
