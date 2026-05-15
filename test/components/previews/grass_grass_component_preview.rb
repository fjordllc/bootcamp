# frozen_string_literal: true

class GrassGrassComponentPreview < ViewComponent::Preview
  def default
    user = OpenStruct.new(
      login_name: 'yamada',
      graduated?: false
    )
    times = build_times(Date.current)

    render(Grass::GrassComponent.new(
             user: user,
             times: times,
             target_end_date: Date.current,
             path: :root_path
           ))
  end

  def graduated_user
    user = OpenStruct.new(
      login_name: 'tanaka',
      graduated?: true
    )
    times = build_times(Date.current)

    render(Grass::GrassComponent.new(
             user: user,
             times: times,
             target_end_date: Date.current,
             path: :root_path
           ))
  end

  private

  def build_times(end_date)
    start_date = end_date.prev_year
    (start_date..end_date).each_with_object({}) do |date, hash|
      hash[date.strftime('%Y-%m-%d')] = rand(0..5) if rand < 0.3
    end
  end
end
