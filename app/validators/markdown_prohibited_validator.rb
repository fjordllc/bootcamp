# frozen_string_literal: true

class MarkdownProhibitedValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    invalid_format = /\A([-+#*>`]+|\d+\.)\s+|([~|_*])\S.*?\2/.match(value)
    return unless invalid_format

    record.errors.add(attribute, "にマークダウン記法は使用できません： #{invalid_format}")
  end
end
