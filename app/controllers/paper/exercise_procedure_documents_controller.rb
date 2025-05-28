# frozen_string_literal: true

class Paper::ExerciseProcedureDocumentsController < PaperController
  GRANT_COURSE = 'Railsエンジニア（Reスキル講座認定）'
  def show
    ignore_category_names = %w[就職活動（Reスキル）]
    @categories = Course.find_by(title: GRANT_COURSE).categories.where.not(name: ignore_category_names)
  end
end
