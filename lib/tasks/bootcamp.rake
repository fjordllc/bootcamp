# frozen_string_literal: true

require "#{Rails.root}/config/environment"

namespace :bootcamp do
  namespace :oneshot do
    desc "Create a course and set all users."
    task "create_a_course_and_set_all_users" do
      Course.create!(
        title: "Railsプログラマー",
        description: "Linux, Web, Ruby, Railsなどを学んでWebプログラマーになろう。"
      )

      User.update_all(course: Course.first)

      Category.all.each do |category|
        category.courses << Course.first
      end
    end

    desc "Set all graduated_on"
    task "set_all_graduated_on" do
      User.where(graduation: true, graduated_on: nil).order(:created_at).each do |user|
        puts "Update graduated_on: #{user.login_name}"
        user.update!(graduated_on: "2000-01-01")
      end
    end

    desc "Set all retired_on"
    task "set_all_riteired_on" do
      User.where(retire: true, retired_on: nil).order(:created_at).each do |user|
        puts "Update retired_on: #{user.login_name}"
        user.update!(retired_on: "2000-01-01")
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
