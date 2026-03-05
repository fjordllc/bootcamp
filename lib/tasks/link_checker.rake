# frozen_string_literal: true

namespace :link_checker do
  desc 'Run broken link checker and notify results to Discord'
  task run: :environment do
    Rails.logger.info '[LinkChecker] リンクチェック開始'

    documents = Page.all + Practice.all
    links = LinkChecker::Extractor.extract_links_from_multi(documents)
    Rails.logger.info "[LinkChecker] #{documents.size}件のドキュメントから#{links.size}件のリンクを抽出"

    summary = LinkChecker::Checker.check_broken_links(links)

    if summary.present?
      Rails.logger.info "[LinkChecker] リンク切れを検出:\n#{summary}"
      ChatNotifier.message(summary, username: 'リンクチェッカー', webhook_url: ENV['DISCORD_BUG_WEBHOOK_URL'])
    else
      Rails.logger.info '[LinkChecker] リンク切れなし'
    end

    Rails.logger.info '[LinkChecker] リンクチェック完了'
  end
end
