# frozen_string_literal: true

require_relative 'exprs'
require_relative 'sql_blocks'

module UnifiedSearch
  module Helpers
    include UnifiedSearch::Exprs
    include UnifiedSearch::SqlBlocks
  end
end

UnifiedSearchHelpers = UnifiedSearch::Helpers
