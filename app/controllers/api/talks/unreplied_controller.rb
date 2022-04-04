# frozen_string_literal: true

class API::Talks::UnrepliedController < API::BaseController
  PAGER_NUMBER = 20

  def index
    @talks = Talk.eager_load(user: [:company, { avatar_attachment: :blob }])
                 .unreplied
                 .order(updated_at: :desc)
    @talks =
      if params[:search_word]
        @talks.search_by_user_keywords(params[:search_word])
      else
        @talks.page(params[:page]).per(PAGER_NUMBER)
      end
  end
end
