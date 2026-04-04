# frozen_string_literal: true

class TagEditComponentPreview < ViewComponent::Preview
  def default
    tag = OpenStruct.new(
      id: 1,
      name: 'Ruby'
    )

    render(Tag::EditComponent.new(tag: tag))
  end

  def long_tag_name
    tag = OpenStruct.new(
      id: 2,
      name: 'オブジェクト指向プログラミング'
    )

    render(Tag::EditComponent.new(tag: tag))
  end
end
