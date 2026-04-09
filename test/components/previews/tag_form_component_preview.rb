# frozen_string_literal: true

class TagFormComponentPreview < ViewComponent::Preview
  ReportTaggable = Struct.new(:id, :tag_list)
  QuestionTaggable = Struct.new(:id, :tag_list)

  class << ReportTaggable
    def to_s = 'Report'
  end

  class << QuestionTaggable
    def to_s = 'Question'
  end

  def default
    taggable = ReportTaggable.new(1, %w[Ruby Rails Web])

    render(Tag::FormComponent.new(
             taggable: taggable,
             param_name: 'report[tag_list]',
             input_id: 'report_tag_list'
           ))
  end

  def readonly
    taggable = ReportTaggable.new(1, %w[Linux Docker])

    render(Tag::FormComponent.new(
             taggable: taggable,
             param_name: 'report[tag_list]',
             input_id: 'report_tag_list',
             editable: false
           ))
  end

  def empty_tags
    taggable = QuestionTaggable.new(1, [])

    render(Tag::FormComponent.new(
             taggable: taggable,
             param_name: 'question[tag_list]',
             input_id: 'question_tag_list'
           ))
  end
end
