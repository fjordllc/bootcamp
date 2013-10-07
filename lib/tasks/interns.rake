require "#{Rails.root}/config/environment"

namespace :intern do
  desc 'Replace practices'
  task :replace_practice do
    include SeedHelper
    Practice.delete_all
    import 'practices'
  end
  
  desc 'Dump practices'
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

  desc 'Import categories.'
  task 'import_categories' do
    require 'active_record/fixtures'
    ActiveRecord::FixtureSet.create_fixtures \
      "#{Rails.root}/db/fixtures", 'categories'
  end

  desc 'Reset position'
  task 'reset_position' do
    Practice.order('id').each do |practice|
      practice.position = practice.id
      practice.save!
    end
  end
end
