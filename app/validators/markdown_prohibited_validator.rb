# frozen_string_literal: true

class MarkdownProhibitedValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return unless /\A\s*\u3000*[#-*+>`]\s+/.match?(value)

    record.errors.add(attribute, 'には禁止されている記号が含まれています')
  end
end
