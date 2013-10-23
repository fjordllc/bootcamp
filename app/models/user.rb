class User < ActiveRecord::Base
  as_enum :job, %i(programmer designer)
  as_enum :purpose, %i(get_job change_job start_venture skill_up)
  authenticates_with_sorcery!

  belongs_to :company
  has_many :learnings

  has_many :completed_learnings,
    -> { where(status_cd: 1) },
    class_name: 'Learning'

  has_many :completed_practices,
    through: :completed_learnings,
    source: :practice

  has_many :active_learnings,
    -> { where(status_cd: 0) },
    class_name: 'Learning'

  has_many :active_practices,
    through: :active_learnings,
    source:  :practice

  validates :company_id, presence: true
  validates :email,      presence: true, uniqueness: true
  validates :first_name, presence: true
  validates :last_name,  presence: true
  validates :login_name, presence: true, uniqueness: true

  validates :password, {
    length: { minimum: 4 },
    confirmation: true,
    if: :password_required?
  }

  def completed_percentage
    completed_my_practices_size.to_f / my_practices_size.to_f * 100
  end

  def completed_practices_size(category)
    completed_practices.where(category_id: category.id).size
  end

  def completed_percentage_by(category)
    completed_practices_size(category).to_f / category.practices.size.to_f * 100
  end

  def full_name
    "#{self.last_name} #{self.first_name}"
  end

  def twitter_id
    twitter_url.sub(/^https:\/\/twitter.com\//, '')
               .sub(/^http:\/\/twitter.com\//, '')
               .sub(/^@/, '')
  end

  def admin?
    id == 1
  end

  def part(now = Time.now)
    weeks = ((now.beginning_of_week - created_at.beginning_of_week) / 60 / 60 / 24 / 7).to_i
    weeks.even? ? 'learning_week' : 'working_week'
  end

  def learning_week?(now = Time.now)
    part == 'learning_week'
  end

  def working_week?(now = Time.now)
    not learning_week?(now)
  end

  def active?
    updated_at > 2.weeks.ago
  end

  private
    def my_practices_size
      Practice.where(target_cd: [0, target_cd]).size
    end

    def completed_my_practices_size
      completed_practices.where(target_cd: [0, target_cd]).size
    end

    def target_cd
      job_cd == 0 ? 1 : 2
    end

    def password_required?
      new_record? || password.present?
    end
end
