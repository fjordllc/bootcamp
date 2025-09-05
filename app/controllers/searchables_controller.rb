# frozen_string_literal: true

class SearchablesController < ApplicationController
  PER_PAGE = 50

  def index
    @word = params[:word].to_s
    @document_type = params[:document_type]&.to_sym || :all

    searcher = Searcher.new(
      keyword: search_params[:word],
      document_type: search_params[:document_type],
      only_me: search_params[:only_me].present?,
      current_user:
    )
    results = searcher.search
    @searchables = Kaminari.paginate_array(results).page(params[:page]).per(PER_PAGE)

    user_ids = @searchables.map(&:user_id).compact.uniq
    @users_by_id = User.where(id: user_ids).index_by(&:id)
    @talks_by_user_id = Talk.where(user_id: user_ids).index_by(&:user_id)
  end

  private

  def search_params
    params.permit(:word, :document_type, :only_me)
  end
end
