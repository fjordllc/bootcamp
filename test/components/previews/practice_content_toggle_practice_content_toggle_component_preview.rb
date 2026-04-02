# frozen_string_literal: true

class PracticeContentTogglePracticeContentToggleComponentPreview < ViewComponent::Preview
  def practice_content
    practice = OpenStruct.new(
      id: 1,
      title: 'Rubyの基礎を理解する',
      description: "## 概要\nRubyの基本的な文法を学びます。\n\n- 変数\n- 条件分岐\n- 繰り返し",
      goal: "Rubyの基本文法を使ってプログラムが書けるようになる"
    )

    render(PracticeContentToggle::PracticeContentToggleComponent.new(
      content_type: :practice,
      practice: practice
    ))
  end

  def goal_content
    practice = OpenStruct.new(
      id: 2,
      title: 'Git & GitHubの使い方',
      description: "Gitの基本操作を学びます。",
      goal: "- Gitの基本コマンドが使える\n- GitHubでPRが作れる\n- コードレビューができる"
    )

    render(PracticeContentToggle::PracticeContentToggleComponent.new(
      content_type: :goal,
      practice: practice
    ))
  end
end
