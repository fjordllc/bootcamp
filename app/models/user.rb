# frozen_string_literal: true

class User < ActiveRecord::Base
  ADMIN_EMAILS = %w(komagata@fjord.jp machidanohimitsu@gmail.com)

  as_enum :purpose, %i(get_job change_job start_venture skill_up)
  authenticates_with_sorcery!

  belongs_to :company
  has_many :learnings
  has_many :comments, dependent: :destroy
  has_many :reports, dependent: :destroy
  has_many :checks
  has_many :footprints, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :images
  has_many :products

  has_many :send_notifications, class_name: "Notification", foreign_key: "sender_id"

  has_many :completed_learnings,
    -> { where(status_cd: 1) },
    class_name: "Learning"

  has_many :completed_practices,
    through: :completed_learnings,
    source: :practice

  has_many :active_learnings,
    -> { where(status_cd: 0) },
    class_name: "Learning"

  has_many :active_practices,
    through: :active_learnings,
    source:  :practice

  validates :company_id, presence: true
  validates :email,      presence: true, uniqueness: true
  validates :first_name, presence: true
  validates :last_name,  presence: true
  validates :login_name, presence: true, uniqueness: true
  validates :nda, presence: true
  validates :password, length: { minimum: 4 }, confirmation: true, if: :password_required?
  validates :twitter_account, length: { maximum: 15 }, format: { allow_blank: true, with: /\A\w+\z/, message: I18n.t("errors.messages.only_alphanumeric_and_underscore")  }

  has_attached_file :face, styles: { small: "32x32>", normal: "72x72#" }
  validates_attachment_content_type :face, content_type: /\Aimage\/.*\z/

  scope :in_school, -> { where(graduation: false) }
  scope :graduated, -> { where(graduation: true) }
  scope :retired, -> { where(retire: true) }
  scope :advisers, -> { where(adviser: true) }
  scope :not_advisers, -> { where(adviser: false) }
  scope :student, -> { where(mentor: false, graduation: false, adviser: false, retire: false) }
  scope :active, -> { where("updated_at > ?", 1.month.ago) }
  scope :inactive, -> { where("updated_at <= ?", 1.month.ago) }
  scope :mentor, -> { where(mentor: true) }
  scope :working, -> { active.where(adviser: false, graduation: false, retire: false).order(updated_at: :desc) }

  scope :admin, -> { where(email: ADMIN_EMAILS) }

  def away?
    self.updated_at <= 10.minutes.ago
  end

  def completed_percentage
    completed_practices.size.to_f / Practice.count.to_f * 100
  end

  def completed_practices_size(category)
    completed_practices.where(category_id: category.id).size
  end

  def completed_percentage_by(category)
    completed_practices_size(category).to_f / category.practices.size.to_f * 100
  end

  def full_name
    "#{last_name} #{first_name}"
  end

  def admin?
    ADMIN_EMAILS.include?(email)
  end

  def active?
    updated_at > 2.weeks.ago
  end

  def nexway?
    company.name == "株式会社ネクスウェイ"
  end

  def has_checked_product_of?(*practices)
    products.where(practice: practices).any?(&:checked?)
  end

  def practices_with_checked_product
    Practice.where(products: products.checked)
  end

  private

    def password_required?
      new_record? || password.present?
    end
end
