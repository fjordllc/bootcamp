class TaskRequest < ApplicationRecord
  belongs_to :user
  belongs_to :practice
  has_attached_file :task,
                    styles: { medium: "500x500>", thumb: "100x100>" }
  validates_attachment :task,
                       content_type: { content_type: ["image/jpeg", "image/gif", "image/png", "application/zip", "application/x-zip"] },
                       size:         { less_than: 1.megabytes }

  validates :user_id, presence: true, uniqueness: { scope: :practice_id }
  validates :practice_id, presence: true, uniqueness: { scope: :user_id }
  validates :passed, inclusion: { in: [true, false] }
  validates :content, presence: true, length: { minimum: 5, maximum: 2000 }

  scope :passed, -> { where(passed: true,).order(created_at: :desc) }
  scope :non_passed, -> { where(passed: false,).order(created_at: :desc) }

  before_task_post_process :skip_for_zip

  def skip_for_zip
    !%w(application/zip application/x-zip).include?(task_content_type)
  end

  def task_is_image_file?
    %w(image/jpeg image/gif image/png).include?(self.task_content_type)
  end

  def task_is_zip_file?
    %w(application/zip application/x-zip).include?(self.task_content_type)
  end
end
