# frozen_string_literal: true

class Paper::ExerciseProcedureDocumentController < PaperController
  def show
    ignore_practice_ids = [6, 19, 23, 25, 57]
    @categories = Course.find(1).categories.where.not(id: ignore_practice_ids)
  end
end
