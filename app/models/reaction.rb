# frozen_string_literal: true

class Reaction < ApplicationRecord
  enum :kind, {
    thumbsup: 0,
    thumbsdown: 1,
    smile: 2,
    confused: 3,
    tada: 4,
    heart: 5,
    rocket: 6,
    eyes: 7,
    hundred: 8,
    flexed: 9,
    okwoman: 10,
    loudlycrying: 11,
    raised_hands: 12,
    pray: 13
  }

  belongs_to :user
  belongs_to :reactionable, polymorphic: true

  validates :user_id, uniqueness: { scope: %i[reactionable_id reactionable_type kind] }

  def self.emojis
    negative_emojis = %w[thumbsdown confused]
    @emojis ||= kinds.keys.zip(%w[👍 👎 😄 😕 🎉 ❤️ 🚀 👀 💯 💪 🙆‍♀️ 😭 🙌 🙏]).to_h.with_indifferent_access.filter { |e| negative_emojis.exclude?(e) }
  end

  def self.available_emojis
    emojis.map { |key, value| { kind: key, value: } }
  end
end
