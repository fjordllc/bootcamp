# frozen_string_literal: true

class SearchablesController < ApplicationController
  PER_PAGE = 50

  def index
    @word = params[:word].to_s
    @document_type = params[:document_type]&.to_sym || :all

    searchables = Searcher.search(@word, document_type: @document_type, current_user:)

    if params[:only_logged_in_user] && %i[all practices users].exclude?(document_type_param)
      searchables = searchables.select do |searchable|
        searchable.user_id == current_user.id
      end
    end

    @searchables = Kaminari.paginate_array(searchables.uniq).page(params[:page]).per(PER_PAGE)

    user_ids = @searchables.map(&:user_id).compact.uniq
    @users_by_id = User.where(id: user_ids).index_by(&:id)
    @talks_by_user_id = Talk.where(user_id: user_ids).index_by(&:user_id)
  end
end
