# frozen_string_literal: true

class Search
  def self.search(word)
    reports = Report.ransack(title_or_description_cont_all: word).result
    pages = Page.ransack(title_or_body_cont_all: word).result
    practices = Practice.ransack(title_or_description_or_goal_cont_all: word).result
    questions = Question.ransack(title_or_description_cont_all: word).result
    announcements = Announcement.ransack(title_or_description_cont_all: word).result
    reports + pages + practices + questions + announcements
  end
end
