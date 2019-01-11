# frozen_string_literal: true

module Bootcamp
  class Setup
    class << self
      def attachment
        return false if User.first.avatar.attached?

        User.all.each do |user|
          filename = "#{user.login_name}.jpg"
          path = Rails.root.join("test", "fixtures", "files", "users", "avatars", filename)
          user.avatar.attach(io: open(path), filename: filename) if File.exist?(path)
        end
      end
    end
  end
end
