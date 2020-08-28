# frozen_string_literal: true

module TagValidatable
  def tag_list_validation
    if tag_list.any? { |tag| tag =~ /\A(?=.*\s+|.*　+).*\z/ }
      errors.add(:tag_list, "に空白が含まれています")
    end
  end
end
