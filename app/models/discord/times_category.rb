# frozen_string_literal: true

module Discord
  class TimesCategory
    class_attribute :default_times_category_id, instance_accessor: false
    CATEGORY_NAME_KEYWORD = 'ひとりごと・分報'

    class << self
      def categorize_by_initials(name)
        return Discord::TimesCategory.default_times_category_id if name.blank?

        times_categories = Discord::Server.categories(keyword: CATEGORY_NAME_KEYWORD)

        category_type = /\A[0-9]/.match?(name) ? '数字' : name.upcase[0]
        found_times_category = times_categories&.find { |times_category| /#{category_type}/.match? times_category.name }
        found_times_category&.id || Discord::TimesCategory.default_times_category_id
      end
    end
  end
end
