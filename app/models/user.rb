class User < ActiveRecord::Base
  as_enum :job, [:programmer, :designer]
  authenticates_with_sorcery!

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
    source: :practice

  validates_length_of :password, minimum: 4, if: :password
  validates_confirmation_of :password, if: :password
  validates :login_name, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true
  validates :first_name, presence: true
  validates :last_name, presence: true

  def my_practices_size
    Practice.where(target_cd: job_cd + 1).size.to_f
  end

  def completed_my_practices_size
    completed_practices.where(target_cd: job_cd + 1).size.to_f
  end

  def completed_percentage
    completed_my_practices_size / my_practices_size * 100
  end
end
