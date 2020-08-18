# frozen_string_literal: true

module PageDecorator
  def tags_input_tag
    render partial: "tags_input", locals: { taggable_model: self }
  end
end
