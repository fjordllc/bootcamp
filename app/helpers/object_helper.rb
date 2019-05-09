# frozen_string_literal: true

module ObjectHelper
  def object_id(object)
    if object == @report
      :report_id
    elsif object == @question
      :question_id
    elsif object == @product
      :product_id
    end
  end
end
