class RegularEventSkipDate < ApplicationRecord
  belongs_to :regular_event
  before_validation do
    Rails.logger.debug "[SkipDate before_validation] id=#{id.inspect} skip_on=#{skip_on.inspect} today=#{Time.zone.today}"
  end

  after_validation do
    Rails.logger.debug "[SkipDate after_validation] id=#{id.inspect} errors=#{errors.full_messages}"
  end
  # validates :skip_on, presence: true, unless: :marked_for_destruction?
  validates :skip_on, comparison: { greater_than_or_equal_to: -> { Time.zone.today }, message: 'は本日以降の日付を入力してください' }, if: :will_save_change_to_skip_on?

  scope :from_today, -> { where('skip_on >= ?', Time.zone.today) }

  # validates :skip_on,
  #           uniqueness: { scope: :regular_event_id, message: 'は既に登録されています' },
  #           allow_blank: true
  # validate :validate_skip_on_in_past

  # def validate_skip_on_in_past
  #   errors.add(:skip_on, 'は過去の日付は入力できません') if skip_on.present? && skip_on < Time.zone.today
  # end

  # validate :validate_skip_on_matches_repeat_rules
  # def validate_skip_on_matches_repeat_rules
  #   #    - skip_onの曜日を取得
  #   #    - repeat_rulesのday_of_the_weekだけの配列を作成
  #   # 　　- include?的な感じでチェックしてなければエラー
  #   # return if skip_on.nil?

  #   wday = skip_on.wday
  #   repeat_rules_wday = regular_event.regular_event_repeat_rules
  #   errors.add(:skip_on, 'は定期開催曜日のみ登録してください') unless repeat_rules_wday.include?(wday)
  # end
end
