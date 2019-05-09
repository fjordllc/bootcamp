# frozen_string_literal: true

require "#{Rails.root}/config/environment"

namespace :bootcamp do
  namespace :oneshot do
    desc "Set free falg"
    task :set_free_flag  do
      User.where(admin: false, mentor: false, adviser: false, free: false).each do |user|
        user.free = true
        user.save(validate: false)
        puts "make free: #{user.login_name}"
      end
    end

    desc "Migrate finished_at"
    task :migrate_finished_at do
      LearningTime.find_each do |learning_time|
        if learning_time.started_at > learning_time.finished_at
          puts "Update learing_times ##{learning_time.id}"
          learning_time.update!(finished_at: learning_time.finished_at + 1.day)
        end
      end
    end
  end

  desc "Replace practices"
  task :replace_practice do
    include SeedHelper
    Practice.delete_all
    import "practices"
  end

  desc "Dump practices"
  task :dump_practice do
    Practice.all.each do |practice|
      puts <<-EOS
  practice_#{practice.id}:
    id: #{practice.id}
    title: "#{practice.title}"
    description: "#{practice.description}"
    goal: "#{practice.goal}"
    target_cd: #{practice.target_cd}

      EOS
    end
  end

  desc "Reset practice position"
  task "reset_practice_position" do
    Practice.order("id").each do |practice|
      practice.position = practice.id
      practice.save!
    end
  end

  desc "Reset category position"
  task "reset_category_position" do
    Category.order("id").each do |category|
      category.position = category.id
      category.save!
    end
  end

  desc "Let sleep unactive users."
  task "sleep" do
    users = User.in_school.
                 not_advisers.
                 where("accessed_at < ?", 3.months.ago)
    users.each do |user|
      user.update_attributes!(sleep: true)
      puts "#{user.login_name}, R.I.P."
    end
  end
end
