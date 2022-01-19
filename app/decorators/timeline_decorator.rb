# frozen_string_literal: true

module TimelineDecorator
  def format_to_channel
    {
      id: id,
      description: description,
      created_at: created_at,
      updated_at: updated_at,
      user: user.format_to_channel
    }
  end
end
