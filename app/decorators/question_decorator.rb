# frozen_string_literal: true

module QuestionDecorator
  def taggable
    render partial: "tags_input", locals: { taggable_model: self }
  end
end
