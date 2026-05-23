# frozen_string_literal: true

class API::SearchablesController < API::BaseController
  PER_PAGE = 50

  rescue_from ArgumentError, with: :render_bad_request

  def index
    results = searcher.search
    @searchables = Kaminari.paginate_array(results).page(params[:page]).per(PER_PAGE)

    render json: {
      searchables: @searchables.map { |searchable| searchable_json(searchable) },
      total_pages: @searchables.total_pages
    }
  end

  private

  def searcher
    Searcher.new(
      keyword: params[:word],
      document_type: params[:document_type],
      only_me: ActiveModel::Type::Boolean.new.cast(params[:only_me]),
      current_user:,
      mode: params[:mode]
    )
  end

  def searchable_json(searchable)
    {
      type: searchable.search_model_name,
      id: searchable.id,
      title: searchable.search_title,
      label: searchable.search_label,
      content: searchable.search_content,
      url: searchable.search_url,
      user: user_json(searchable),
      updated_at: searchable.updated_at
    }
  end

  def user_json(searchable)
    user = search_user(searchable)
    return unless user

    {
      id: user.id,
      login_name: user.login_name,
      name: user.name
    }
  end

  def search_user(searchable)
    return searchable if searchable.is_a?(User)
    return searchable.user if searchable.respond_to?(:user)

    nil
  end

  def render_bad_request(error)
    render json: { message: error.message }, status: :bad_request
  end
end
