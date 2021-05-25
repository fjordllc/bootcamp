# frozen_string_literal: true

module Bootcamp
  class Setup
    class << self
      def fixtures_dir
        Rails.env.test? ? 'test' : 'db'
      end

      def attachment
        attach_user_avatar!
        attach_company_logo!
        attach_reference_book_cover!
      end

      private

      def attach_user_avatar!
        User.all.each do |user|
          filename = "#{user.login_name}.jpg"
          path = Rails.root.join("#{fixtures_dir}/fixtures/files/users/avatars/#{filename}")
          if File.exist?(path)
            user.avatar.attach(io: File.open(path), filename: filename)
            user.resize_avatar!
          end
        end
      end

      def attach_company_logo!
        Company.order(:created_at).each_with_index do |company, i|
          filename = "#{i + 1}.jpg"
          dir = Rails.root.join("#{fixtures_dir}/fixtures/files/companies/logos")
          path = "#{dir}/#{filename}"
          unless File.exist?(path)
            filename = 'default.jpg'
            path = "#{dir}/#{filename}"
          end
          company.logo.attach(io: File.open(path), filename: filename)
        end
      end

      def attach_reference_book_cover!
        ReferenceBook.order(:created_at).each_with_index do |book, i|
          filename = "#{i + 1}.jpg"
          path = Rails.root.join("#{fixtures_dir}/fixtures/files/reference_books/covers/#{filename}")
          if File.exist?(path)
            book.cover.attach(io: File.open(path), filename: filename)
            book.resize_cover!
          end
        end
      end
    end
  end
end
