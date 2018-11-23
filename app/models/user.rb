# frozen_string_literal: true

class User < ActiveRecord::Base
  authenticates_with_sorcery!

  belongs_to :company
  belongs_to :course
  has_many :learnings
  has_many :comments,      dependent: :destroy
  has_many :reports,       dependent: :destroy
  has_many :checks,        dependent: :destroy
  has_many :footprints,    dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :images,        dependent: :destroy
  has_many :products,      dependent: :destroy
  has_many :questions,     dependent: :destroy
  has_many :announcements, dependent: :destroy

  has_many :send_notifications,
    class_name:  "Notification",
    foreign_key: "sender_id",
    dependent:   :destroy

  has_many :completed_learnings,
    -> { where(status_cd: 1) },
    class_name: "Learning",
    dependent:  :destroy

  has_many :completed_practices,
    through:   :completed_learnings,
    source:    :practice,
    dependent: :destroy

  has_many :active_learnings,
    -> { where(status_cd: 0) },
    class_name: "Learning",
    dependent:  :destroy

  has_many :active_practices,
    through:   :active_learnings,
    source:    :practice,
    dependent: :destroy

  validates :company_id, presence: true
  validates :email,      presence: true, uniqueness: true
  validates :first_name, presence: true
  validates :last_name,  presence: true
  validates :login_name, presence: true, uniqueness: true
  validates :nda, presence: true
  validates :password, length: { minimum: 4 }, confirmation: true, if: :password_required?
  validates :twitter_account,
    length: { maximum: 15 },
    format: {
      allow_blank: true,
      with: /\A\w+\z/,
      message: I18n.t("errors.messages.only_alphanumeric_and_underscore")
    }

  has_attached_file :face, styles: { small: "32x32>", normal: "72x72#" }
  validates_attachment_content_type :face, content_type: /\Aimage\/.*\z/

  scope :in_school, -> { where(graduated_on: nil) }
  scope :graduated, -> { where.not(graduated_on: nil) }
  scope :retired, -> { where.not(retired_on: nil) }
  scope :advisers, -> { where(adviser: true) }
  scope :not_advisers, -> { where(adviser: false) }
  scope :student, -> {
    where(
      mentor: false,
      graduated_on: nil,
      adviser: false,
      retired_on: nil
    )
  }
  scope :active, -> { where(updated_at: 1.month.ago..Float::INFINITY) }
  scope :inactive, -> {
    where(
      updated_at: -Float::INFINITY..1.month.ago,
      adviser: false,
      retired_on: nil,
      graduated_on: nil
    )
  }
  scope :year_end_party, -> { where(retired_on: nil) }
  scope :mentor, -> { where(mentor: true) }
  scope :working, -> {
    active.where(
      adviser: false,
      graduated_on: nil,
      retired_on: nil
    ).order(updated_at: :desc)
  }
  scope :admins, -> { where(admin: true) }

  def away?
    self.updated_at <= 10.minutes.ago
  end

  def completed_percentage
    completed_practices.size.to_f / course.practices.count.to_f * 100
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

  def active?
    updated_at > 1.month.ago
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
