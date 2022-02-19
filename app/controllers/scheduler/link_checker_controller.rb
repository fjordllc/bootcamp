# frozen_string_literal: true

class Scheduler::LinkCheckerController < SchedulerController
  def show
    documents = Page.all + Practice.all
    links = LinkChecker::Extractor.extract_links_from_multi(documents)
    summary_of_broken_links = LinkChecker::Checker.check_broken_links(links)

    ChatNotifier.message(summary_of_broken_links, username: 'リンクチェッカー', webhook_url: ENV['DISCORD_BUG_WEBHOOK_URL'])

    render plain: summary_of_broken_links
  end
end
