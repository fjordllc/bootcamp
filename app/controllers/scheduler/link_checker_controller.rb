# frozen_string_literal: true

class Scheduler::LinkCheckerController < SchedulerController
  def show
    documents = Page.all + Practice.all
    links = LinkChecker::Extractor.extract_links_from_multi(documents)
    checker = LinkChecker::Checker.new(links)

    ChatNotifier.message(checker.summary_of_broken_links, username: 'リンクチェッカー', webhook_url: ENV['DISCORD_BUG_WEBHOOK_URL'])

    render plain: checker.summary_of_broken_links
  end
end
