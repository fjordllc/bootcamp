# frozen_string_literal: true

require_relative 'exprs'
require_relative 'sql_blocks'

module UnifiedSearchHelpers
  include UnifiedSearch::Exprs
  include UnifiedSearch::SqlBlocks
end
