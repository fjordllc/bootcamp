# frozen_string_literal: true

class TaggableType
  TAGGABLE_CLASSES = {
    'User' => User,
    'Page' => Page,
    'Movie' => Movie,
    'Question' => Question,
    'Article' => Article
  }.freeze

  def self.resolve(type)
    TAGGABLE_CLASSES[type] if type.is_a?(String)
  end
end
