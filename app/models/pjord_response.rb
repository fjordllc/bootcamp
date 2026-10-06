# frozen_string_literal: true

require 'schematist'

class PjordResponse < Schematist::Schema
  description 'ピヨルドがユーザーに公開する返答本文'

  string :body,
         description: 'ユーザーにそのまま見せる本文。検索やツール使用などの内部手順説明は含めない。'
end
