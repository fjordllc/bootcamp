# frozen_string_literal: true

module Bootcamp
  class Setup
    class << self
      def attachment
        return false if User.first.avatar.attached?

        User.all.each do |user|
          filename = "#{user.login_name}.jpg"
          path = Rails.root.join("test", "fixtures", "files", "users", "avatars", filename)
          unless File.exist?(path)
            filename = "default.jpg"
            path = Rails.root.join("test", "fixtures", "files", "users", "avatars", filename)
          end
          user.avatar.attach(io: open(path), filename: filename)
        end

        Company.order(:created_at).each_with_index do |company, i|
          filename = "#{i + 1}.jpg"
          dir = Rails.root.join("test", "fixtures", "files", "companies", "logos")
          path = "#{dir}/#{filename}"
          unless File.exist?(path)
            filename = "default.jpg"
            path = "#{dir}/#{filename}"
          end
          company.logo.attach(io: open(path), filename: filename)
        end
      end
    end
  end
end
