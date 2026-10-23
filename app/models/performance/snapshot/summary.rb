# frozen_string_literal: true

module Performance
  class Snapshot
    class Summary
      attr_reader :worst_known, :known_count, :expected_count, :unknown_count

      def initialize(cells, complete: true)
        ratings = cells.filter_map(&:rating)
        @worst_known = %i[poor attention good].find { |value| ratings.include?(value) }
        @expected_count = cells.length
        @known_count = ratings.length
        @unknown_count = expected_count - known_count
        @complete = complete && unknown_count.zero?
      end

      def rating
        return worst_known if %i[poor attention].include?(worst_known)
        return :good if @complete && worst_known == :good

        nil
      end

      def label
        { good: '良好', attention: '要注意', poor: '要改善', nil => '判定待ち' }.fetch(rating)
      end

      def sort_order
        return 0 if rating == :poor
        return 1 if rating == :attention
        return 2 if rating.nil?

        3
      end
    end
  end
end
