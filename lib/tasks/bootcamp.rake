# frozen_string_literal: true

require Rails.root.join('config/environment')

# rubocop:disable Metrics/BlockLength
namespace :bootcamp do
  desc 'Find broken links in practices, pages.'
  task find_broken_link: :environment do
    LinkChecker.new.notify_error_url
  end

  desc 'Migration on production.'
  task migrate: :environment do
    Rake::Task['db:migrate'].execute

    # staging
    Rake::Task['db:reset'].execute if ENV['DB_NAME'] == 'bootcamp_staging'

    # production
    Rake::Task['data:migrate'].execute if ENV['DB_NAME'] == 'bootcamp_production'
  end

  desc 'DB Reset on staging.'
  task reset: :environment do
    Rake::Task['db:reset'].execute if ENV['DB_NAME'] == 'bootcamp_staging'
  end

  desc 'Reset Stripe test DB.'
  task reset_stripe: :environment do
    customer = Stripe::Customer.create(email: 'hatsuno@fjord.jp')
    Subscription.new.create(
      customer.id
    )
  end

  namespace :oneshot do
    desc 'Cloud Build Task'
    task cloudbuild: :environment do
      puts '== START Cloud Build Task =='

      receiver_login_name = if Rails.env.development? || ENV['DB_NAME'] == 'bootcamp_staging'
                              'komagata'
                            elsif Rails.env.production?
                              'AudioStakes'
                            end
      receiver = User.find_by(login_name: receiver_login_name)
      sender = User.find_by(login_name: 'machida')
      link = Product.first.path
      now = Time.current

      2.times do |i|
        Notification.create!(
          user: receiver,
          sender: sender,
          message: "【動作確認用】「通知元リンクが同じ」通知のなかで「作成日時が最新かつ同値」である通知#{i + 1}つ目",
          link: link,
          created_at: now
        )
      end

      puts '== END   Cloud Build Task =='
    end
  end

  namespace :statistics do
    desc 'save learning minute statistics'
    task save_learning_minute_statistics: :environment do
      Practice.save_learning_minute_statistics
    end
  end
end
# rubocop:enable Metrics/BlockLength
