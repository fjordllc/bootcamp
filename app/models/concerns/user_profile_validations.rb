# frozen_string_literal: true

module UserProfileValidations
  extend ActiveSupport::Concern

  included do
    before_validation :convert_blank_of_address_to_nil

    validates :facebook_url, :feed_url, :blog_url,
              format: {
                allow_blank: true,
                with: URI::DEFAULT_PARSER.make_regexp(%w[http https]),
                message: 'は「http://example.com」や「https://example.com」のようなURL形式で入力してください'
              }

    validates :login_name, exclusion: { in: User::RESERVED_LOGIN_NAMES, message: 'に使用できない文字列が含まれています' }

    validates :login_name, length: { minimum: 3, message: 'は3文字以上にしてください。' }

    validates :show_study_streak, inclusion: { in: [true, false] }

    validates :diploma_file, content_type: { in: ['application/pdf'], message: 'はPDF形式にしてください' }

    validates :country_code, inclusion: { in: ISO3166::Country.codes }, allow_nil: true

    validates :subdivision_code, inclusion: { in: ->(user) { UserRegion.new(user).subdivision_codes } }, allow_nil: true, if: -> { country_code.present? }
  end
end
