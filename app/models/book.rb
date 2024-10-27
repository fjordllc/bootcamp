# frozen_string_literal: true

class Book < ApplicationRecord
  include ActionView::Helpers::AssetUrlHelper

  COVER_SIZE = [100, 150].freeze
  has_many :practices_books, dependent: :destroy
  has_many :practices, through: :practices_books
  has_one_attached :cover
  validates :title, presence: true
  validates :price, presence: true, numericality: { only_integer: true }
  validates :page_url, presence: true
  validates :cover,
            content_type: %w[image/png image/jpg image/jpeg],
            size: { less_than: 10.megabytes }

  def cover_url
    default_image_path = '/images/books/covers/default.svg'
    if cover.attached?
      cover.variant(resize_to_limit: COVER_SIZE).processed.url
    else
      image_url default_image_path
    end
  rescue ActiveStorage::FileNotFoundError, ActiveStorage::InvariableError
    image_url default_image_path
  end

  def coursebook?(course_practices)
    practices.any? do |practice|
      course_practices.any? { |course_practice| practice.id == course_practice.id }
    end
  end

  def self.filtered_books(status, course)
    books = Book
            .with_attached_cover
            .includes(:practices)
            .order(updated_at: :desc, id: :desc)

    course_practices = course.extract_practices
    mustread_or_all =
      status == 'mustread' ? books.select { |book| book.practices_books.any?(&:must_read) } : books
    mustread_or_all.select { |book| book.coursebook?(course_practices) }
  end
end
