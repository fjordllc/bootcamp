# frozen_string_literal: true

module Taggable
  extend ActiveSupport::Concern

  included do
    acts_as_taggable
    validate :contains_space
    validate :contains_one_dot_only
  end

  def contains_space
    return unless tag_list.any? { |tag| tag =~ /\A(?=.*\s+|.*　+).*\z/ }

    errors.add(:tag_list, 'に空白が含まれています')
  end

  # contains_spaceに追加できるが分かりやすいコードを書けないため、
  # パフォーマンスを犠牲にして、別の関数にした。
  # 分かりやすいコードが書ける or パフォーマンスが問題になったら、
  # contains_space内にこの関数の処理を追加する。
  def contains_one_dot_only
    return unless tag_list.any? { |tag| tag == '.' }

    errors.add(:tag_list, 'にドット1つだけのタグが含まれています')
  end
end
