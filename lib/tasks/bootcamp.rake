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

  desc 'Copy practices from rails course to reskill course.'
  task copy_practices: :environment do
    sufix = '（Reスキル）'
    slug = '-reskill'
    rails_course = Course.find_by(title: 'Railsエンジニア')
    reskill_course = Course.find_by(title: 'Railsエンジニア（Reスキル講座認定）')

    if rails_course && reskill_course
      Course.transaction do
        # Copy categories
        rails_course.categories.each do |category|
          Category.exists?(name: category.name + sufix) && next

          new_category = category.dup
          new_category.id = nil
          new_category.name = category.name + sufix
          new_category.slug = category.slug + slug
          puts "Copying category: #{new_category.name}"
          reskill_course.categories << new_category
          new_category.save!

          # Copy practices
          category.practices.each do |practice|
            Practice.exists?(title: practice.title + sufix) && next

            new_practice = practice.dup
            new_practice.id = nil
            new_practice.title = practice.title + sufix
            new_practice.category_id = new_category.id
            new_practice.source_id = practice.id

            new_practice.categories << new_category

            puts "Copying practice: #{new_practice.title}"
            new_practice.save!

            # Copy reports
            practice.reports.each do |report|
              new_practice.reports << report
            end

            # Copy books
            practice.books.each do |book|
              new_practice.books << book
            end
          end
        end
        puts 'Practices copied successfully.'
      end
    else
      puts 'One or both courses not found.'
    end
  end

  namespace :oneshot do
    desc 'Cloud Build Task'
    task cloudbuild: :environment do
      puts '== START Cloud Build Task =='

      Rake::Task['bootcamp:copy_practices'].invoke

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
