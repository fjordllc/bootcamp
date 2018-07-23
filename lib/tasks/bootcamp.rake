require "#{Rails.root}/config/environment"

namespace :bootcamp do
  namespace :oneshot do
    desc "Change format that twitter url change to twitter account"
    task :change_twitter_format do
      User.transaction do
        User.where.not(twitter_account: nil).find_each do |user|
          new_twitter_account = user.twitter_account.sub(%r(\Ahttps://twitter.com/), "")
                                                    .sub(%r(\Ahttp://twitter.com/), "")

          puts "id: #{user.id}, old: #{user.twitter_account}, new: #{new_twitter_account}"
          if user.twitter_account != new_twitter_account
            user.update!(twitter_account: new_twitter_account)
          end
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

  desc "Import categories."
  task "import_categories" do
    require "active_record/fixtures"
    ActiveRecord::FixtureSet.create_fixtures \
      "#{Rails.root}/db/fixtures", "categories"
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

  desc "Import reports."
  task "import_reports" do
    require "active_record/fixtures"
    ActiveRecord::FixtureSet.create_fixtures \
      "#{Rails.root}/db/fixtures", "reports"
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
