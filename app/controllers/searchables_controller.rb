# frozen_string_literal: true

class SearchablesController < ApplicationController
  before_action :require_login

<<<<<<< HEAD
  def index; end
=======
  def index
    @result = Searcher.search(params[:word], document_type: document_type_param)
    @searchables = Kaminari.paginate_array(@result).page(params[:page]).per(50)
  end

  private

  def document_type_param
    params[:document_type]&.to_sym || :all
  end
>>>>>>> b9d44671 (検索結果を非同期化)
end
