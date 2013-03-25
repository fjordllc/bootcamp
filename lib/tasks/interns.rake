require "#{Rails.root}/config/environment"

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
