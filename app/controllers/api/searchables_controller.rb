# frozen_string_literal: true

class API::SearchablesController < API::BaseController
  PAGER_NUMBER = 50

  def index
    result = Searcher.search(params[:word], document_type: document_type_param)

    if params[:only_me] && %i[all practices users].exclude?(document_type_param)
      result = result.select do |record|
        record.user_id == current_user.id
      end
    end

    @searchables = Kaminari.paginate_array(result).page(params[:page]).per(PAGER_NUMBER)
  end

  private

  def document_type_param
    params[:document_type]&.to_sym || :all
  end
end
