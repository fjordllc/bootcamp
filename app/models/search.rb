# frozen_string_literal: true

class Search
  def self.search(word)
    reports = Report.ransack(title_or_description_cont_all: word).result
    pages = Page.ransack(title_or_body_cont_all: word).result
    reports + pages
  end
end
