# frozen_string_literal: true

class API::Talks::UnrepliedController < API::BaseController
  PAGER_NUMBER = 20

  def index
    @talks = Talk.eager_load(user: [:company, { avatar_attachment: :blob }])
                 .unreplied
                 .order(updated_at: :desc, id: :asc)
    @talks =
      if params[:search_word]
        @talks.merge(
          User.search_by_keywords({ word: params[:search_word] })
              .unscope(where: :retired_on)
        )
      else
        @talks.page(params[:page]).per(PAGER_NUMBER)
      end
  end
end
