# frozen_string_literal: true

class Scheduler::LinkCheckerController < SchedulerController
  def show
    documents = Page.all + Practice.all
    links = LinkChecker::Extractor.extract_all_links(documents)
    checker = LinkChecker::Checker.new(links)
    checker.notify_broken_links

    render plain: checker.errors.join("\n")
  end
end
