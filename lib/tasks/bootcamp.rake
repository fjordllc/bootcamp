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

  desc 'Disconnect all DB user.'
  task disconnect_all_user: :environment do
    ActiveRecord::Base.connection.execute "SELECT pid FROM pg_stat_activity WHERE datname = 'bootcamp_staging'"
  end

  namespace :oneshot do
    desc 'Cloud Build Task'
    task cloudbuild: :environment do
      puts '== START Cloud Build Task =='

      User.all.each(&:create_talk!)

      if ENV['DB_NAME'] == 'bootcamp_staging'
        Article.where(wip: false).where(published_at: nil).find_each do |article|
          article.published_at = article.created_at
          article.save!(validate: false)
        end
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
