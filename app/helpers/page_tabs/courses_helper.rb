# frozen_string_literal: true

module PageTabs
  module CoursesHelper
    def courses_page_tabs(course, active_tab:)
      tabs = []
      tabs << { name: 'プラクティス', link: course_practices_path(course) }
      tabs << { name: '書籍', link: course_books_path(course) }
      render PageTabsComponent.new(tabs:, active_tab:)
    end
  end
end
