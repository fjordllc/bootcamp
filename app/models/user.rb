class User < ActiveRecord::Base
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

  has_attached_file :face, styles: { small: "32x32>", normal: "60x60#" }
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

  def twitter_id
    twitter_url.sub(/^https:\/\/twitter.com\//, "")
               .sub(/^http:\/\/twitter.com\//, "")
               .sub(/^@/, "")
  end

  def admin?
    %w(komagata@fjord.jp machidanohimitsu@gmail.com).include?(email)
  end

  def active?
    updated_at > 2.weeks.ago
  end

  def nexway?
    company.name == "株式会社ネクスウェイ"
  end

  private

    def password_required?
      new_record? || password.present?
    end
end
