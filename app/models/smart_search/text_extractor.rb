# frozen_string_literal: true

module SmartSearch
  # 後方互換性のためのラッパーモジュール
  # 実際のテキスト抽出は各モデルの text_for_embedding メソッドで行う
  module TextExtractor
    module_function

    def extract(record)
      return nil unless record.respond_to?(:text_for_embedding)

      record.text_for_embedding
    end
  end
end
