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

  namespace :oneshot do
    desc 'Cloud Build Task'
    task cloudbuild: :environment do
      puts '== START Cloud Build Task =='
      Product.add_latest_commented_at
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
