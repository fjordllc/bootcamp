# frozen_string_literal: true

namespace :concat_name do
  desc "ユーザーの名前を結合し、nameとname_kanaカラムに保存"
  task :concat_name do
    puts "\n== Saving name and name_kana =="
    User.find_each do |user|
      user.name = user.full_name
      user.name_kana = user.kana_full_name
      user.save! validate: false
    end
  end

  Rake::Task["db:prepare"].enhance do
    Rake::Task["concat_name:concat_name"].invoke
  end
end
