# frozen_string_literal: true

class TagFormComponentPreview < ViewComponent::Preview
  def default
    taggable = OpenStruct.new(
      id: 1,
      tag_list: %w[Ruby Rails Web],
      class: OpenStruct.new(name: 'Report')
    )

    render(Tag::FormComponent.new(
      taggable: taggable,
      param_name: 'report[tag_list]',
      input_id: 'report_tag_list'
    ))
  end

  def readonly
    taggable = OpenStruct.new(
      id: 1,
      tag_list: %w[Linux Docker],
      class: OpenStruct.new(name: 'Report')
    )

    render(Tag::FormComponent.new(
      taggable: taggable,
      param_name: 'report[tag_list]',
      input_id: 'report_tag_list',
      editable: false
    ))
  end

  def empty_tags
    taggable = OpenStruct.new(
      id: 1,
      tag_list: [],
      class: OpenStruct.new(name: 'Question')
    )

    render(Tag::FormComponent.new(
      taggable: taggable,
      param_name: 'question[tag_list]',
      input_id: 'question_tag_list'
    ))
  end
end
