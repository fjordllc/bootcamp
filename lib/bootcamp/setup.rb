# frozen_string_literal: true

module Bootcamp
  class Setup
    class << self
      def fixtures_dir
        Rails.env.test? ? 'test' : 'db'
      end

      def attachment
        attach_mentor_profile_image!
        attach_user_avatar!
        attach_company_logo!
        attach_book_cover!
        attach_authored_book_cover!
      end

      private

      def attach_mentor_profile_image!
        mentors = User.where(mentor: true)
        mentors.each do |mentor|
          filename =
            File.exist?(Rails.root.join("#{fixtures_dir}/fixtures/files/users/avatars/#{mentor.login_name}.jpg")) ? "#{mentor.login_name}.jpg" : 'default.jpg'
          path = Rails.root.join("#{fixtures_dir}/fixtures/files/users/avatars/#{filename}")
          mentor.profile_image.attach(io: File.open(path), filename:)
        end
      end

      def attach_user_avatar!
        User.all.each do |user|
          filename = "#{user.login_name}.jpg"
          path = Rails.root.join("#{fixtures_dir}/fixtures/files/users/avatars/#{filename}")
          user.avatar.attach(io: File.open(path), filename:) if File.exist?(path)
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
          company.logo.attach(io: File.open(path), filename:)
        end
      end

      def attach_book_cover!
        Book.order(:created_at).each_with_index do |book, i|
          filename = "#{i + 1}.jpg"
          path = Rails.root.join("#{fixtures_dir}/fixtures/files/books/covers/#{filename}")
          book.cover.attach(io: File.open(path), filename:) if File.exist?(path)
        end
      end

      def attach_authored_book_cover!
        AuthoredBook.order(:created_at).each_with_index do |authored_book, i|
          filename = "#{i + 1}.png"
          path = Rails.root.join("#{fixtures_dir}/fixtures/files/authored_books/#{filename}")
          authored_book.cover.attach(io: File.open(path), filename:) if File.exist?(path)
        end
      end
    end
  end
end
