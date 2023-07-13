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
    trace = Rake.application.options.trace
    Rake.application.options.trace = true
    case ENV['DB_NAME']
    when 'bootcamp_staging'
      Rake::Task['db:reset'].invoke
    when 'bootcamp_production'
      Rake::Task['db:migrate:with_data'].invoke
    end
    Rake.application.options.trace = trace
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
    sql = "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = 'bootcamp_staging' and application_name = 'bin/rails'"
    ActiveRecord::Base.connection.execute sql
  end

  desc 'Validate all users.'
  task validate_all_users: :environment do
    User.order(:id).each do |user|
      next if user.valid?

      puts "Invalid user: #{user.id}, #{user.login_name}"
      puts user.errors.full_messages
    end
  end

  namespace :oneshot do
    desc 'Cloud Build Task'
    task cloudbuild: :environment do
      puts '== START Cloud Build Task =='

      User.order(:id).each(&:update_sad_streak)

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
