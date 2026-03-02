# frozen_string_literal: true

module PairWorkDecorator
  def important?
    comments.blank? && !solved?
  end
end
